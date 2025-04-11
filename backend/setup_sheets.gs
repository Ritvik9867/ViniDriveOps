// Script to automatically set up Google Sheets structure for ViniDriveOps

function setupSheets() {
  const ss = SpreadsheetApp.getActive();
  
  // Create or get sheets
  const driversSheet = getOrCreateSheet(ss, 'Drivers');
  const tripsSheet = getOrCreateSheet(ss, 'Trips');
  const expensesSheet = getOrCreateSheet(ss, 'Expenses');
  const complaintsSheet = getOrCreateSheet(ss, 'Complaints');
  const advancesSheet = getOrCreateSheet(ss, 'Advances');
  const repaymentsSheet = getOrCreateSheet(ss, 'Repayments');

  // Set up headers and validation rules for each sheet
  setupDriversSheet(driversSheet);
  setupTripsSheet(tripsSheet);
  setupExpensesSheet(expensesSheet);
  setupComplaintsSheet(complaintsSheet);
  setupAdvancesSheet(advancesSheet);
  setupRepaymentsSheet(repaymentsSheet);

  // Format all sheets
  const sheets = [driversSheet, tripsSheet, expensesSheet, complaintsSheet, advancesSheet, repaymentsSheet];
  sheets.forEach(sheet => formatSheet(sheet));

  // Add data validation and protection
  sheets.forEach(sheet => protectSheet(sheet));
}

function getOrCreateSheet(spreadsheet, sheetName) {
  let sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(sheetName);
  }
  return sheet;
}

function setupDriversSheet(sheet) {
  const headers = [
    'ID', 'Email', 'Phone', 'Name', 'Total Earnings', 'Total Expenses',
    'Cash Collected', 'Is Active', 'Total KM', 'Trip KM', 'Burning KM', 'Advance Balance'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  
  // Add data validation for Is Active column
  const isActiveRule = SpreadsheetApp.newDataValidation()
    .requireCheckbox()
    .build();
  sheet.getRange('H2:H').setDataValidation(isActiveRule);
}

function setupTripsSheet(sheet) {
  const headers = [
    'ID', 'Driver ID', 'Amount', 'Payment Mode', 'Payment Type',
    'Timestamp', 'Start KM', 'End KM', 'Cash Collected', 'Toll'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  
  // Add data validation for Payment Mode
  const paymentModeRule = SpreadsheetApp.newDataValidation()
    .requireValueInList(['Cash', 'Online', 'Mixed'])
    .build();
  sheet.getRange('D2:D').setDataValidation(paymentModeRule);
}

function setupExpensesSheet(sheet) {
  const headers = [
    'ID', 'Driver ID', 'Amount', 'Type', 'Timestamp', 'Receipt URL', 'Status'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  
  // Add data validation for Status
  const statusRule = SpreadsheetApp.newDataValidation()
    .requireValueInList(['Pending', 'Approved', 'Rejected'])
    .build();
  sheet.getRange('G2:G').setDataValidation(statusRule);
}

function setupComplaintsSheet(sheet) {
  const headers = [
    'ID', 'Driver ID', 'Description', 'Timestamp', 'Status', 'Resolution'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
}

function setupAdvancesSheet(sheet) {
  const headers = [
    'ID', 'Driver ID', 'Amount', 'Date', 'Reason', 'Status', 'Approved By'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
}

function setupRepaymentsSheet(sheet) {
  const headers = [
    'ID', 'Advance ID', 'Driver ID', 'Amount', 'Date', 'Payment Mode'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
}

function formatSheet(sheet) {
  // Format headers
  const headerRange = sheet.getRange(1, 1, 1, sheet.getLastColumn());
  headerRange
    .setBackground('#4285f4')
    .setFontColor('white')
    .setFontWeight('bold')
    .setHorizontalAlignment('center');
  
  // Auto-resize columns
  sheet.autoResizeColumns(1, sheet.getLastColumn());
  
  // Freeze header row
  sheet.setFrozenRows(1);
}

function protectSheet(sheet) {
  // Protect header row
  const protection = sheet.getRange(1, 1, 1, sheet.getLastColumn()).protect();
  protection.setDescription('Protected Headers');
  
  // Allow only owner to edit headers
  protection.removeEditors(protection.getEditors());
  protection.addEditor(Session.getEffectiveUser());
}

// Add menu item to run setup
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('ViniDriveOps')
    .addItem('Setup Sheets', 'setupSheets')
    .addToUi();
}