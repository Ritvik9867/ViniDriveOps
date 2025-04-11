// Spreadsheet ID
const SPREADSHEET_ID = '1mbAdiwJDeyYN1IwdZdlw42UwJz5mwWTqZA1FeKlHkqw';

// Sheet Names
const SHEET_NAMES = {
  DRIVERS: 'Drivers',
  TRIPS: 'Trips',
  EXPENSES: 'Expenses',
  COMPLAINTS: 'Complaints',
  ADVANCES: 'Advances',
  REPAYMENTS: 'Repayments'
};

// JWT Configuration
const JWT_SECRET = 'YOUR_JWT_SECRET';
const TOKEN_EXPIRY = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

// API Configuration
const API_VERSION = 'v1';
const ALLOWED_ORIGINS = ['*']; // Update with your app's domain

// Image Storage Configuration
const DRIVE_FOLDER_ID = 'YOUR_GOOGLE_DRIVE_FOLDER_ID';

// Response Status Codes
const STATUS_CODES = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_ERROR: 500
};

// Sheet Column Configurations
const DRIVERS_COLUMNS = {
  ID: 0,
  EMAIL: 1,
  PHONE: 2,
  NAME: 3,
  TOTAL_EARNINGS: 4,
  TOTAL_EXPENSES: 5,
  CASH_COLLECTED: 6,
  IS_ACTIVE: 7,
  TOTAL_KM: 8,
  TRIP_KM: 9,
  BURNING_KM: 10,
  ADVANCE_BALANCE: 11
};

const TRIPS_COLUMNS = {
  ID: 0,
  DRIVER_ID: 1,
  AMOUNT: 2,
  PAYMENT_MODE: 3,
  PAYMENT_TYPE: 4,
  TIMESTAMP: 5,
  START_KM: 6,
  END_KM: 7,
  CASH_COLLECTED: 8,
  TOLL: 9
};

const EXPENSES_COLUMNS = {
  ID: 0,
  DRIVER_ID: 1,
  AMOUNT: 2,
  TYPE: 3,
  TIMESTAMP: 4,
  RECEIPT_URL: 5,
  STATUS: 6
};

// Utility Functions
function getSheetConfig(sheetName) {
  const configs = {
    'Drivers': DRIVERS_COLUMNS,
    'Trips': TRIPS_COLUMNS,
    'Expenses': EXPENSES_COLUMNS
  };
  return configs[sheetName] || {};
}

// Export configurations
function getConfig() {
  return {
    DRIVERS_SHEET_ID,
    TRIPS_SHEET_ID,
    EXPENSES_SHEET_ID,
    COMPLAINTS_SHEET_ID,
    ADVANCES_SHEET_ID,
    JWT_SECRET,
    TOKEN_EXPIRY,
    API_VERSION,
    ALLOWED_ORIGINS,
    DRIVE_FOLDER_ID,
    STATUS_CODES
  };
}