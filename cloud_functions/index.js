const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Configuration, OpenAIApi } = require('openai');

// Initialize Firebase Admin
admin.initializeApp();

// OpenAI configuration
const configuration = new Configuration({
  apiKey: functions.config().openai.key,
});
const openai = new OpenAIApi(configuration);

// Test AI connection
exports.testAI = functions.https.onCall(async (data, context) => {
  try {
    // Test OpenAI connection
    const response = await openai.listModels();
    
    return {
      available: true,
      model: 'gpt-3.5-turbo',
      models: response.data.data.map(model => model.id),
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('AI test failed:', error);
    return {
      available: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
});

// Process cooking commands with AI
exports.processCookingCommand = functions.https.onCall(async (data, context) => {
  try {
    const { command, timestamp, userId } = data;
    
    console.log(`Processing cooking command: ${command} from user: ${userId}`);
    
    // AI processing with OpenAI
    const aiResponse = await processCommandWithAI(command);
    
    // Extract cooking parameters
    const cookingParams = extractCookingParameters(aiResponse);
    
    // Log the command
    await logCommand(userId, command, aiResponse, cookingParams);
    
    // Send notification if needed
    if (cookingParams.action) {
      await sendNotification(userId, cookingParams.action, cookingParams);
    }
    
    return {
      success: true,
      response: aiResponse,
      action: cookingParams.action,
      parameters: cookingParams.parameters,
      timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error('Command processing failed:', error);
    return {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
});

// AI processing function
async function processCommandWithAI(command) {
  try {
    const prompt = `
    You are a cooking assistant. Analyze the following command and provide a structured response.
    
    Command: "${command}"
    
    Respond with JSON format:
    {
      "intent": "cooking_intent",
      "action": "start_cooking|heat_food|set_temperature|set_timer|stop_cooking",
      "parameters": {
        "dish_name": "name of dish if mentioned",
        "temperature": "temperature in celsius if mentioned",
        "duration": "duration in minutes if mentioned",
        "mode": "cooking mode if mentioned"
      },
      "response": "natural language response to user",
      "confidence": 0.95
    }
    
    Examples:
    - "عايز اعمل الطبق اللي اسمه كباب" → start_cooking with dish_name: "كباب"
    - "اسخن الطبق" → heat_food with default parameters
    - "ضبط درجة الحرارة على 200" → set_temperature with temperature: 200
    - "ضبط التايمر على 30 دقيقة" → set_timer with duration: 30
    `;
    
    const completion = await openai.createChatCompletion({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful cooking assistant that responds in Arabic and English.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 500,
      temperature: 0.7,
    });
    
    const response = completion.data.choices[0].message.content;
    
    // Try to parse JSON response
    try {
      return JSON.parse(response);
    } catch (parseError) {
      // If JSON parsing fails, return structured response
      return {
        intent: 'cooking_intent',
        action: 'unknown',
        parameters: {},
        response: response,
        confidence: 0.8
      };
    }
    
  } catch (error) {
    console.error('AI processing failed:', error);
    throw new Error(`AI processing failed: ${error.message}`);
  }
}

// Extract cooking parameters from AI response
function extractCookingParameters(aiResponse) {
  try {
    const { action, parameters } = aiResponse;
    
    // Validate and clean parameters
    const cleanParams = {
      dish_name: parameters.dish_name || null,
      temperature: parseInt(parameters.temperature) || null,
      duration: parseInt(parameters.duration) || null,
      mode: parameters.mode || null
    };
    
    // Set default values based on action
    switch (action) {
      case 'start_cooking':
        if (!cleanParams.temperature) cleanParams.temperature = 180;
        if (!cleanParams.duration) cleanParams.duration = 30;
        break;
      case 'heat_food':
        if (!cleanParams.temperature) cleanParams.temperature = 100;
        if (!cleanParams.duration) cleanParams.duration = 5;
        break;
      case 'set_temperature':
        if (!cleanParams.temperature) cleanParams.temperature = 180;
        break;
      case 'set_timer':
        if (!cleanParams.duration) cleanParams.duration = 30;
        break;
    }
    
    return {
      action: action,
      parameters: cleanParams
    };
    
  } catch (error) {
    console.error('Parameter extraction failed:', error);
    return {
      action: 'unknown',
      parameters: {}
    };
  }
}

// Log command to Firestore
async function logCommand(userId, command, aiResponse, cookingParams) {
  try {
    const logData = {
      userId: userId,
      command: command,
      aiResponse: aiResponse,
      cookingParams: cookingParams,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      processed: true
    };
    
    await admin.firestore()
      .collection('cooking_commands')
      .add(logData);
      
    console.log(`Command logged for user: ${userId}`);
    
  } catch (error) {
    console.error('Failed to log command:', error);
  }
}

// Send notification to user
async function sendNotification(userId, action, parameters) {
  try {
    const message = {
      notification: {
        title: 'Cooking Command Processed',
        body: `Your command "${action}" has been processed successfully.`
      },
      data: {
        type: 'cooking_command',
        action: action,
        parameters: JSON.stringify(parameters),
        timestamp: new Date().toISOString()
      },
      topic: `user_${userId}` // Send to specific user topic
    };
    
    const response = await admin.messaging().send(message);
    console.log(`Notification sent: ${response}`);
    
  } catch (error) {
    console.error('Failed to send notification:', error);
  }
}

// HTTP endpoint for testing
exports.testEndpoint = functions.https.onRequest((req, res) => {
  res.json({
    message: 'Google Cloud Functions for Cooking Assistant is running!',
    timestamp: new Date().toISOString(),
    endpoints: [
      'testAI',
      'processCookingCommand',
      'testEndpoint'
    ]
  });
});

// Scheduled function to clean old logs
exports.cleanOldLogs = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30); // Keep logs for 30 days
    
    const snapshot = await admin.firestore()
      .collection('cooking_commands')
      .where('timestamp', '<', cutoffDate)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    console.log(`Cleaned ${snapshot.size} old command logs`);
    
  } catch (error) {
    console.error('Failed to clean old logs:', error);
  }
});

// Background function for processing queued commands
exports.processQueuedCommands = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  try {
    const snapshot = await admin.firestore()
      .collection('cooking_commands')
      .where('processed', '==', false)
      .limit(10)
      .get();
    
    for (const doc of snapshot.docs) {
      try {
        const commandData = doc.data();
        
        // Process the command
        const aiResponse = await processCommandWithAI(commandData.command);
        const cookingParams = extractCookingParameters(aiResponse);
        
        // Update the document
        await doc.ref.update({
          processed: true,
          aiResponse: aiResponse,
          cookingParams: cookingParams,
          processedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`Processed queued command: ${commandData.command}`);
        
      } catch (error) {
        console.error(`Failed to process queued command: ${error.message}`);
        
        // Mark as failed
        await doc.ref.update({
          processed: false,
          error: error.message,
          failedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
    
  } catch (error) {
    console.error('Failed to process queued commands:', error);
  }
});
