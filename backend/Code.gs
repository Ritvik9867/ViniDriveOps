// Google Apps Script backend for ViniDriveOps

// Spreadsheet IDs
const DRIVERS_SHEET_ID = 'YOUR_DRIVERS_SHEET_ID';
const TRIPS_SHEET_ID = 'YOUR_TRIPS_SHEET_ID';
const EXPENSES_SHEET_ID = 'YOUR_EXPENSES_SHEET_ID';
const COMPLAINTS_SHEET_ID = 'YOUR_COMPLAINTS_SHEET_ID';
const ADVANCES_SHEET_ID = 'YOUR_ADVANCES_SHEET_ID';

// Drive folder ID for storing images
const DRIVE_FOLDER_ID = 'YOUR_DRIVE_FOLDER_ID';

// Web app doGet function - handles GET requests
function doGet(e) {
  try {
    const action = e.parameter.action;
    const token = e.parameter.token;

    if (!action) {
      return sendResponse(false, 'No action specified');
    }

    // Verify token for protected endpoints
    if (action !== 'login' && action !== 'register') {
      if (!verifyToken(token)) {
        return sendResponse(false, 'Invalid or expired token');
      }
    }

    switch (action) {
      case 'getAllDrivers':
        return handleGetAllDrivers();
      default:
        return sendResponse(false, 'Invalid action');
    }
  } catch (error) {
    return sendResponse(false, 'Server error: ' + error.toString());
  }
}

// Web app doPost function - handles POST requests
function doPost(e) {
  try {
    const action = e.parameter.action;
    const token = e.parameter.token;
    const data = JSON.parse(e.postData.contents);

    if (!action) {
      return sendResponse(false, 'No action specified');
    }

    // Verify token for protected endpoints
    if (action !== 'login' && action !== 'register') {
      if (!verifyToken(token)) {
        return sendResponse(false, 'Invalid or expired token');
      }
    }

    switch (action) {
      case 'login':
        return handleLogin(data);
      case 'register':
        return handleRegister(data);
      case 'submitOdReading':
        return handleSubmitOdReading(data);
      case 'logTrip':
        return handleLogTrip(data);
      case 'submitCNGExpense':
        return handleSubmitCNGExpense(data);
      case 'submitComplaint':
        return handleSubmitComplaint(data);
      case 'submitAdvanceRepayment':
        return handleSubmitAdvanceRepayment(data);
      case 'getDriverDashboard':
        return handleGetDriverDashboard(data);
      case 'getAdminDashboard':
        return handleGetAdminDashboard(data);
      case 'updateApprovalStatus':
        return handleUpdateApprovalStatus(data);
      case 'addAdvance':
        return handleAddAdvance(data);
      case 'uploadImage':
        return handleUploadImage(data);
      default:
        return sendResponse(false, 'Invalid action');
    }
  } catch (error) {
    return sendResponse(false, 'Server error: ' + error.toString());
  }
}

// Authentication handlers
function handleLogin(data) {
  const sheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const values = sheet.getDataRange().getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][1] === data.email && values[i][2] === data.password) {
      const token = generateToken();
      // Store token in cache
      CacheService.put('token_' + values[i][0], token, 21600); // 6 hours expiry
      
      return sendResponse(true, 'Login successful', {
        token: token,
        userId: values[i][0],
        role: values[i][4],
      });
    }
  }
  
  return sendResponse(false, 'Invalid credentials');
}

function handleRegister(data) {
  const sheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  
  // Check if email already exists
  const values = sheet.getDataRange().getValues();
  if (values.some(row => row[1] === data.email)) {
    return sendResponse(false, 'Email already registered');
  }
  
  // Generate unique ID
  const id = Utilities.getUuid();
  
  // Add new driver
  sheet.appendRow([
    id,
    data.email,
    data.password,
    data.name,
    'driver', // role
    data.phone,
    new Date(), // registration date
    true, // isActive
  ]);
  
  return sendResponse(true, 'Registration successful');
}

// Image upload handler
function handleUploadImage(data) {
  const folder = DriveApp.getFolderById(DRIVE_FOLDER_ID);
  const blob = Utilities.newBlob(Utilities.base64Decode(data.image), 'image/jpeg', data.fileName);
  const file = folder.createFile(blob);
  file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
  
  return sendResponse(true, 'Image uploaded successfully', {
    imageUrl: file.getUrl(),
  });
}

// Helper functions
function sendResponse(success, message, data = null) {
  const response = ContentService.createTextOutput(JSON.stringify({
    success: success,
    message: message,
    data: data,
  }));
  response.setMimeType(ContentService.MimeType.JSON);
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  response.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  return response;
}

function generateToken() {
  return Utilities.getUuid();
}

function verifyToken(token) {
  if (!token) return false;
  // Check if token exists in cache
  return CacheService.get('token_' + token) !== null;
}

// Handler for submitting odometer readings
function handleSubmitOdReading(data) {
  const sheet = SpreadsheetApp.openById(TRIPS_SHEET_ID).getSheetByName('OdometerReadings');
  
  // Add new odometer reading
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.reading,
    data.isStarting,
    data.imageUrl,
    data.timestamp,
    new Date(), // submission time
    true // isValid
  ]);
  
  // Update driver's total KM in Drivers sheet if this is an ending reading
  if (!data.isStarting) {
    const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
    const driverData = driversSheet.getDataRange().getValues();
    const driverRow = driverData.findIndex(row => row[0] === data.userId);
    
    if (driverRow > -1) {
      // Get the last starting reading for this driver
      const readings = sheet.getDataRange().getValues();
      const lastStarting = readings
        .reverse()
        .find(row => row[1] === data.userId && row[3] === true);
      
      if (lastStarting) {
        const kmDriven = data.reading - lastStarting[2];
        // Update total KM driven
        const currentTotal = driverData[driverRow][8] || 0;
        driversSheet.getRange(driverRow + 1, 9).setValue(currentTotal + kmDriven);
      }
    }
  }
  
  return sendResponse(true, 'Odometer reading submitted successfully');
}

// Handler for logging trips
function handleLogTrip(data) {
  const sheet = SpreadsheetApp.openById(TRIPS_SHEET_ID).getSheetByName('Trips');
  
  // Add new trip
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.amount,
    data.startLocation,
    data.endLocation,
    data.startTime,
    data.endTime,
    data.distance,
    data.cashCollected,
    new Date(), // log time
    'pending' // approval status
  ]);
  
  // Update driver's statistics
  const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const driverData = driversSheet.getDataRange().getValues();
  const driverRow = driverData.findIndex(row => row[0] === data.userId);
  
  if (driverRow > -1) {
    const currentEarnings = driverData[driverRow][4] || 0;
    const currentCash = driverData[driverRow][6] || 0;
    const currentTripKm = driverData[driverRow][9] || 0;
    
    driversSheet.getRange(driverRow + 1, 5).setValue(currentEarnings + data.amount);
    driversSheet.getRange(driverRow + 1, 7).setValue(currentCash + data.cashCollected);
    driversSheet.getRange(driverRow + 1, 10).setValue(currentTripKm + data.distance);
  }
  
  return sendResponse(true, 'Trip logged successfully');
}

// Handler for submitting CNG expenses
function handleSubmitCNGExpense(data) {
  const sheet = SpreadsheetApp.openById(EXPENSES_SHEET_ID).getSheetByName('CNGExpenses');
  
  // Add new CNG expense
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.amount,
    data.imageUrl,
    data.timestamp,
    new Date(), // submission time
    'pending', // approval status
    '', // approval notes
    null // approval date
  ]);
  
  // Update driver's expenses (will be adjusted after approval)
  const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const driverData = driversSheet.getDataRange().getValues();
  const driverRow = driverData.findIndex(row => row[0] === data.userId);
  
  if (driverRow > -1) {
    const currentExpenses = driverData[driverRow][5] || 0;
    driversSheet.getRange(driverRow + 1, 6).setValue(currentExpenses + data.amount);
  }
  
  return sendResponse(true, 'CNG expense submitted successfully');
}

// Handler for submitting complaints
function handleSubmitComplaint(data) {
  const sheet = SpreadsheetApp.openById(COMPLAINTS_SHEET_ID).getSheetByName('Complaints');
  
  // Add new complaint
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.type,
    data.description,
    data.imageUrl || '',
    data.timestamp,
    new Date(), // submission time
    'pending', // status
    '', // resolution notes
    null // resolution date
  ]);
  
  return sendResponse(true, 'Complaint submitted successfully');
}

// Handler for submitting advance repayments
function handleSubmitAdvanceRepayment(data) {
  const sheet = SpreadsheetApp.openById(ADVANCES_SHEET_ID).getSheetByName('Repayments');
  
  // Add new repayment
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.amount,
    data.imageUrl,
    data.timestamp,
    new Date(), // submission time
    'pending', // approval status
    '', // approval notes
    null // approval date
  ]);
  
  return sendResponse(true, 'Advance repayment submitted successfully');
}

// Handler for adding new advances
function handleAddAdvance(data) {
  const sheet = SpreadsheetApp.openById(ADVANCES_SHEET_ID).getSheetByName('Advances');
  
  // Add new advance
  sheet.appendRow([
    Utilities.getUuid(),
    data.userId,
    data.amount,
    data.reason,
    data.timestamp,
    new Date(), // submission time
    data.approvedBy,
    'approved' // status (since this is added by admin)
  ]);
  
  // Update driver's advance balance
  const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const driverData = driversSheet.getDataRange().getValues();
  const driverRow = driverData.findIndex(row => row[0] === data.userId);
  
  if (driverRow > -1) {
    const currentAdvance = driverData[driverRow][10] || 0;
    driversSheet.getRange(driverRow + 1, 11).setValue(currentAdvance + data.amount);
  }
  
  return sendResponse(true, 'Advance added successfully');
}

// Handler for updating approval status
function handleUpdateApprovalStatus(data) {
  let sheet;
  let columnIndex;
  
  switch (data.type) {
    case 'cng_expense':
      sheet = SpreadsheetApp.openById(EXPENSES_SHEET_ID).getSheetByName('CNGExpenses');
      columnIndex = 7; // approval status column
      break;
    case 'advance_repayment':
      sheet = SpreadsheetApp.openById(ADVANCES_SHEET_ID).getSheetByName('Repayments');
      columnIndex = 7; // approval status column
      break;
    default:
      return sendResponse(false, 'Invalid approval type');
  }
  
  const values = sheet.getDataRange().getValues();
  const row = values.findIndex(row => row[0] === data.id);
  
  if (row > -1) {
    sheet.getRange(row + 1, columnIndex).setValue(data.status);
    sheet.getRange(row + 1, columnIndex + 1).setValue(data.notes || '');
    sheet.getRange(row + 1, columnIndex + 2).setValue(new Date());
    
    // Update driver's balance if approved
    if (data.status === 'approved') {
      const userId = values[row][1];
      const amount = values[row][2];
      
      const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
      const driverData = driversSheet.getDataRange().getValues();
      const driverRow = driverData.findIndex(row => row[0] === userId);
      
      if (driverRow > -1) {
        if (data.type === 'advance_repayment') {
          const currentAdvance = driverData[driverRow][10] || 0;
          driversSheet.getRange(driverRow + 1, 11).setValue(currentAdvance - amount);
        }
        // For CNG expenses, the amount is already added, so no need to update
      }
    }
    
    return sendResponse(true, 'Status updated successfully');
  }
  
  return sendResponse(false, 'Record not found');
}

// Handler for getting driver dashboard
function handleGetDriverDashboard(data) {
  const userId = data.userId;
  
  // Get driver details
  const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const driverData = driversSheet.getDataRange().getValues();
  const driverRow = driverData.findIndex(row => row[0] === userId);
  
  if (driverRow === -1) {
    return sendResponse(false, 'Driver not found');
  }
  
  // Get recent trips
  const tripsSheet = SpreadsheetApp.openById(TRIPS_SHEET_ID).getSheetByName('Trips');
  const trips = tripsSheet.getDataRange().getValues()
    .filter(row => row[1] === userId)
    .slice(-5) // Get last 5 trips
    .map(row => ({
      id: row[0],
      amount: row[2],
      startLocation: row[3],
      endLocation: row[4],
      startTime: row[5],
      endTime: row[6],
      distance: row[7],
      cashCollected: row[8]
    }));
  
  // Get pending expenses
  const expensesSheet = SpreadsheetApp.openById(EXPENSES_SHEET_ID).getSheetByName('CNGExpenses');
  const pendingExpenses = expensesSheet.getDataRange().getValues()
    .filter(row => row[1] === userId && row[6] === 'pending')
    .map(row => ({
      id: row[0],
      amount: row[2],
      timestamp: row[4],
      status: row[6]
    }));
  
  // Get pending complaints
  const complaintsSheet = SpreadsheetApp.openById(COMPLAINTS_SHEET_ID).getSheetByName('Complaints');
  const pendingComplaints = complaintsSheet.getDataRange().getValues()
    .filter(row => row[1] === userId && row[7] === 'pending')
    .map(row => ({
      id: row[0],
      type: row[2],
      description: row[3],
      timestamp: row[5],
      status: row[7]
    }));
  
  // Calculate today's statistics
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const todaysTrips = tripsSheet.getDataRange().getValues()
    .filter(row => row[1] === userId && new Date(row[5]) >= today);
  
  const todaysStats = todaysTrips.reduce((acc, row) => ({
    earnings: acc.earnings + row[2],
    distance: acc.distance + row[7],
    trips: acc.trips + 1
  }), { earnings: 0, distance: 0, trips: 0 });
  
  return sendResponse(true, 'Dashboard data retrieved successfully', {
    driver: {
      name: driverData[driverRow][3],
      totalEarnings: driverData[driverRow][4],
      totalExpenses: driverData[driverRow][5],
      cashCollected: driverData[driverRow][6],
      totalKmDriven: driverData[driverRow][8],
      tripKm: driverData[driverRow][9],
      burningKm: driverData[driverRow][10],
      advanceBalance: driverData[driverRow][10]
    },
    today: todaysStats,
    recentTrips: trips,
    pendingExpenses: pendingExpenses,
    pendingComplaints: pendingComplaints
  });
}

// Handler for getting admin dashboard
function handleGetAdminDashboard(data) {
  // Get all drivers summary
  const driversSheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const driversData = driversSheet.getDataRange().getValues().slice(1); // Skip header
  
  const driversSummary = driversData
    .filter(row => row[7]) // Only active drivers
    .map(row => ({
      id: row[0],
      name: row[3],
      totalEarnings: row[4],
      totalExpenses: row[5],
      cashCollected: row[6],
      totalKmDriven: row[8],
      tripKm: row[9],
      burningKm: row[10],
      advanceBalance: row[10]
    }));
  
  // Get pending approvals
  const expensesSheet = SpreadsheetApp.openById(EXPENSES_SHEET_ID).getSheetByName('CNGExpenses');
  const pendingExpenses = expensesSheet.getDataRange().getValues()
    .filter(row => row[6] === 'pending')
    .map(row => ({
      id: row[0],
      driverId: row[1],
      amount: row[2],
      timestamp: row[4],
      type: 'cng_expense'
    }));
  
  const repaymentsSheet = SpreadsheetApp.openById(ADVANCES_SHEET_ID).getSheetByName('Repayments');
  const pendingRepayments = repaymentsSheet.getDataRange().getValues()
    .filter(row => row[6] === 'pending')
    .map(row => ({
      id: row[0],
      driverId: row[1],
      amount: row[2],
      timestamp: row[4],
      type: 'advance_repayment'
    }));
  
  // Get recent complaints
  const complaintsSheet = SpreadsheetApp.openById(COMPLAINTS_SHEET_ID).getSheetByName('Complaints');
  const recentComplaints = complaintsSheet.getDataRange().getValues()
    .filter(row => row[7] === 'pending')
    .slice(-10) // Get last 10 complaints
    .map(row => ({
      id: row[0],
      driverId: row[1],
      type: row[2],
      description: row[3],
      timestamp: row[5],
      status: row[7]
    }));
  
  // Calculate today's statistics
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const tripsSheet = SpreadsheetApp.openById(TRIPS_SHEET_ID).getSheetByName('Trips');
  const todaysTrips = tripsSheet.getDataRange().getValues()
    .filter(row => new Date(row[5]) >= today);
  
  const todaysStats = todaysTrips.reduce((acc, row) => ({
    earnings: acc.earnings + row[2],
    distance: acc.distance + row[7],
    trips: acc.trips + 1,
    cashCollected: acc.cashCollected + row[8]
  }), { earnings: 0, distance: 0, trips: 0, cashCollected: 0 });
  
  return sendResponse(true, 'Dashboard data retrieved successfully', {
    drivers: driversSummary,
    pendingApprovals: [...pendingExpenses, ...pendingRepayments],
    recentComplaints: recentComplaints,
    todayStats: todaysStats
  });
}

// Handler for getting all drivers
function handleGetAllDrivers() {
  const sheet = SpreadsheetApp.openById(DRIVERS_SHEET_ID).getSheetByName('Drivers');
  const data = sheet.getDataRange().getValues().slice(1); // Skip header
  
  const drivers = data.map(row => ({
    id: row[0],
    name: row[3],
    email: row[1],
    phone: row[5],
    isActive: row[7]
  }));
  
  return sendResponse(true, 'Drivers retrieved successfully', { drivers });
}