// =============================================================================
// TharlGate: TGSignupData.lsl
// TGSignup: Register riders for a race - Data Operations
// TharlGate, All rights reserved; Copyright 2016-2019; LauraTarnsman Resident
// Work in Progress:
// 1. Fix manage Edit Data button
// 3. Make Load Data button scan for available notecards
// 6. Create Show Data outside of manage menu
// ============================== Upd 08-07-2019 AM ============================
// Configuration
string m_csVersion = "2019.08.08";
integer m_bDebug = FALSE;
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";

// Note Card
key m_keyNumberOfLinesReq;
key m_keyLineReadRequest;
integer m_iTotalNCLines;
integer m_iNCLineNumber;
string m_sStatus;
string m_sManagerList;
string m_sManagerCard;

// Sample Cards
integer m_iDataPage;
string m_sDataCard;

// Manage Race
integer m_iIsManager;
integer m_iManageMode;
integer m_iRegistrationOpen;
string m_sTrackName;
string m_sRaceDate;
string m_sRaceTime;
string m_sRaceStatus;
integer m_iNEntries;
string m_sManageStep;
string m_sKeyMgr;
string m_sMgrName;
integer m_iNLeagues;
string m_sPickRacer;

// Rider Database
string m_sRiderDataList;
integer m_iRacerPage; // Current page of manager Pick Racer dialog

// Current Rider Fields
string m_sKeyRider;
string m_sRiderStep;
string m_sRiderLegacyName;
string m_sRiderDisplayName;
string m_sRiderLeague;
string m_sRiderTeam;
string m_sTharl1;
string m_sTharl2;
string m_sTharl3;
string m_sTharl4;
string m_sTharl5;
string m_keyRiderDlg;

// Comm
integer m_iDialogChannel;
integer m_iDialogHandle;
integer m_iDialogCounter;

//==============================================================================
// ReportMemory: Show version and free memory
//==============================================================================
ReportMemory(key keyDlg)
{
    string sText = "SignupData: Ver. " + m_csVersion +
                   " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
        llRegionSayTo(keyDlg, 0, sText);
    else
        llSay(0, sText);
}
//==============================================================================
// InitializeForm: Perform State Entry initialization
//==============================================================================
InitializeForm()
{
    // Set listener and time-out
    llSetTimerEvent(1);
    llMessageLinked(LINK_THIS, m_iDialogChannel, "m_iDialogChannel", "");

    // Set track tag and manager list
    m_sTrackName = llGetSubString(llGetObjectDesc(), 1, -1);
    m_iNCLineNumber = 0;
    m_sManagerCard = "ManagerList";
    m_keyNumberOfLinesReq = llGetNumberOfNotecardLines(m_sManagerCard);

    // Initialize race information
    m_sRiderDataList = "";
    sGetRaceStatus("");
    llMessageLinked(LINK_THIS, 0, "m_sRiderDataList", m_sRiderDataList);
}
//==============================================================================
// ParseNotecardLine: Add name to manager list
//==============================================================================
ParseNotecardLine(string sLine)
{
    m_sManagerList += "|" + sLine + "|";
}
//==============================================================================
// CheckManager: See if user is in manager list
//==============================================================================
CheckManager(string sUserName)
{
    m_iIsManager = FALSE;
    if (llSubStringIndex(m_sManagerList, "|" + sUserName + "|") >= 0)
        m_iIsManager = TRUE;
    llMessageLinked(LINK_THIS, m_iIsManager, "m_iIsManager", "");
}
//==============================================================================
// sGetRaceStatus: Construct text about current race status
//==============================================================================
string sGetRaceStatus(key keyDlg)
{
    string sRegistration = "closed";
    string sLeagues = "A, B, C, and D Leagues";
    if (m_iNLeagues == 1)
    {
        sLeagues = "A League";
    }
    else if (m_iNLeagues == 2)
    {
        sLeagues = "A and B Leagues";
    }
    else if (m_iNLeagues == 3)
    {
        sLeagues = "A, B, and C Leagues";
    }
    if (m_iRegistrationOpen)
        sRegistration = "open";
    m_iNEntries = iGetNEntries();
    string sStatus = "\n" + m_sTrackName;
    if (m_sRaceDate == "")
    {
        sStatus += ": No race is currently open for registration.\n";
    }
    else
    {
        sStatus += " on " + m_sRaceDate + " at " + m_sRaceTime + "\n" +
                   "Racing " + sLeagues + "\n" +
                   "Registration is " + sRegistration + ". Entries so far: " +
                   (string)m_iNEntries + "\n";
    }

    m_sRaceStatus = sStatus;
    SendTrackInfo(keyDlg);

    return sStatus;
}
//==============================================================================
// iNEntries: Count number of race entries
//==============================================================================
integer iGetNEntries()
{
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    integer iNEntries = llGetListLength(lstEntries);
    return iNEntries;
}
//==============================================================================
// SendTrackInfo: Send track name and race time to RaceForm
//==============================================================================
SendTrackInfo(key keyDlg)
{
    llMessageLinked(LINK_THIS, 0, "m_keyDlg", (string)keyDlg);
    llMessageLinked(LINK_THIS, 0, "m_sTrackName", m_sTrackName);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDate", m_sRaceDate);
    llMessageLinked(LINK_THIS, 0, "m_sRaceTime", m_sRaceTime);
    llMessageLinked(LINK_THIS, m_iNLeagues, "m_iNLeagues", "");
    llMessageLinked(LINK_THIS, m_iRegistrationOpen, "m_iRegistrationOpen", "");
    llMessageLinked(LINK_THIS, 0, "m_sRaceStatus", m_sRaceStatus);
}
//==============================================================================
// PresentRiderData: Display notecard in chat
//==============================================================================
PresentRiderData()
{
    string sMessage = "Your race information:\n" +
                      sGetRaceStatus("") +
                      sGetFullName() + " - " + m_sTrackName + " " + m_sRaceDate + "\n\n";
    sMessage += sAddRiderInfo(1, m_sTharl1);
    sMessage += sAddRiderInfo(2, m_sTharl2);
    sMessage += sAddRiderInfo(3, m_sTharl3);
    sMessage += sAddRiderInfo(4, m_sTharl4);
    sMessage += sAddRiderInfo(5, m_sTharl5);

    llRegionSayTo(m_keyRiderDlg, 0, sMessage);
    llMessageLinked(LINK_THIS, 0, "SendIM", sMessage);
}
//==============================================================================
// sAddRiderInfo: Add a rider to the notecard info
//==============================================================================
string sAddRiderInfo(integer iDiv, string sRiderTharl)
{
    string sMessage;
    string sDiv = " Div " + (string)iDiv;
    string sLeague = m_sRiderLeague + sDiv;

    if (iDiv == 4)
    {
        sLeague = "Open";
    }
    else if (iDiv == 5)
    {
        sLeague = "Bloodbath Div 2";
    }

    if (sRiderTharl != "")
    {
        sMessage += sLeague + " - " +
                    sGetFullName() + " on " + sRiderTharl;
        if (m_sRiderTeam != "")
            sMessage += " riding for " + m_sRiderTeam;
        sMessage += "\n";
    }

    return sMessage;
}
//==============================================================================
// sGetFullName: Get display and legacy name string
//==============================================================================
string sGetFullName()
{
    string sName;

    sName = m_sRiderDisplayName;
    if (m_sRiderDisplayName != m_sRiderLegacyName)
    {
        sName = sName + " (" + m_sRiderLegacyName + ")";
    }

    return sName;
}
//==============================================================================
// DisplayMenu: Call menu from SignupMenus module
//==============================================================================
DisplayMenu(key keyDlg, string sMenuName)
{
    SetDialogListener();
    llMessageLinked(LINK_THIS, 0, sMenuName, keyDlg);
}
//==============================================================================
// SetRiderListener: Open a listener and save the handle
// =============================================================================
SetDialogListener()
{
    if (!m_iDialogHandle)
    {
        m_iDialogHandle = llListen(m_iDialogChannel, "", "", "");
    }
    m_iDialogCounter = 300; // Set dialog countdown to 5 minutes
}
//==============================================================================
// CloseMenu: Close a dialog and its channel
//==============================================================================
CloseMenu()
{
    // Remove dialog listener
    llListenRemove(m_iDialogHandle);
    m_iDialogHandle = FALSE;
    ClearMgr();
}
//==============================================================================
// DialogResponse: Respond to a dialog on the open channel
//==============================================================================
DialogResponse(key keyDlg, string sUserName, string sMessage)
{
    sMessage = llStringTrim(sMessage, STRING_TRIM);
    // DebugSay("DialogResponse sMessage/m_sManageStep(" +
    //     sMessage + "/" + m_sManageStep +")");

    if (sMessage == "Manage")
    {
        // Manage
        if (m_sKeyMgr != "" && m_sKeyMgr != keyDlg)
        {
            string sText = "Banner is currently being managed by " +
                           llGetDisplayName(m_sKeyMgr) + "\nPlease try later.";
            llDialog(keyDlg, sText, [], m_iDialogChannel);
            return;
        }
        m_sManageStep = "MgtStart";
        m_sKeyMgr = keyDlg;
        m_sMgrName = llGetDisplayName(keyDlg);
        DisplayMenu(keyDlg, "MenuManage");
        return;
    }
    else if (keyDlg == m_sKeyMgr)
    {
        // Open Reg
        if (sMessage == "Open Reg")
        {
            m_iRegistrationOpen = TRUE;
            sGetRaceStatus(keyDlg);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Close Reg
        }
        else if (sMessage == "Close Reg")
        {
            m_iRegistrationOpen = FALSE;
            sGetRaceStatus(keyDlg);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Cancel, Close
        }
        else if (sMessage == "Cancel" || sMessage == "Close")
        {
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Clear Data
        }
        else if (sMessage == "Clear Data")
        {
            m_sManageStep = "MgtClear";
            DisplayMenu(keyDlg, "MenuConfirmClear");
        }
        else if (sMessage == "Clear Data!")
        {
            DisplayMenu(keyDlg, "DialogSayClearing");
            llResetScript();
            // New Race
        }
        else if (sMessage == "New Race")
        {
            m_sManageStep = "MgtSetDate";
            m_sRiderDataList = "";
            sGetRaceStatus(keyDlg);
            DisplayMenu(keyDlg, "MenuRaceDate");
        }
        else if (m_sManageStep == "MgtSetDate")
        {
            m_sRaceDate = sMessage;
            m_sManageStep = "MgtSetTime";
            DisplayMenu(keyDlg, "MenuRaceTime");
        }
        else if (m_sManageStep == "MgtSetTime")
        {
            m_sRaceTime = sMessage;
            if (m_sRaceTime != "" && m_sRaceDate != "")
                m_iRegistrationOpen = TRUE;
            sGetRaceStatus(keyDlg);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Race Form
        }
        else if (sMessage == "Race Form")
        {
            sGetRaceStatus(keyDlg);
            llMessageLinked(LINK_THIS, 0, "Race Form", m_sRiderDataList);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Combined Fm
        }
        else if (sMessage == "Combined Fm")
        {
            sGetRaceStatus(keyDlg);
            llMessageLinked(LINK_THIS, 0, "Combined", m_sRiderDataList);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Set # Lgs
        }
        else if (sMessage == "Set # Lgs")
        {
            m_sManageStep = "MgtSetLgs";
            DisplayMenu(keyDlg, "MenuNumLgs");
        }
        else if (m_sManageStep == "MgtSetLgs")
        {
            m_iNLeagues = (integer)sMessage;
            sGetRaceStatus(keyDlg);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Edit Racer
        }
        else if (sMessage == "Edit Racer")
        {
            m_sManageStep = "MgtPickRacer";
            m_iRacerPage = 0;
            m_sPickRacer = "";
            llMessageLinked(LINK_THIS, m_iRacerPage, "m_iRacerPage", "");
            llMessageLinked(LINK_THIS, 0, "m_sRiderDataList", m_sRiderDataList);
            DisplayMenu(keyDlg, "MenuPickRacer");
        }
        else if (m_sManageStep == "MgtPickRacer")
        {
            if (sMessage == ">>")
            {
                m_iRacerPage++;
            }
            else if (sMessage == "<<")
            {
                m_iRacerPage--;
            }
            else
            {
                m_sPickRacer = sMessage;
                m_sManageStep = "MgtPickEdit";
                llMessageLinked(LINK_THIS, 0, "m_sPickRacer", m_sPickRacer);
                return;
            }
            llMessageLinked(LINK_THIS, m_iRacerPage, "m_iRacerPage", "");
            DisplayMenu(keyDlg, "MenuPickRacer");
        }
        else if (m_sManageStep == "MgtPickEdit")
        {
            EditRacer(m_sPickRacer, sMessage);
            sGetRaceStatus(keyDlg);
            llMessageLinked(LINK_THIS, 0, "Show Data", m_sRiderDataList);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Show Data
        }
        else if (sMessage == "Show Data")
        {
            sGetRaceStatus(keyDlg);
            llMessageLinked(LINK_THIS, 0, "Show Data", m_sRiderDataList);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Save Data
        }
        else if (sMessage == "Save Data")
        {
            sGetRaceStatus(keyDlg);
            llMessageLinked(LINK_THIS, 0, "Save Data", m_sRiderDataList);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Load Data
        }
        else if (sMessage == "Load Data")
        {
            sGetRaceStatus(keyDlg);
            m_sManageStep = "MgtPickData";
            m_iDataPage = 0;
            llMessageLinked(LINK_THIS, m_iRacerPage, "m_iDataPage", "");
            DisplayMenu(keyDlg, "MenuPickData");
        }
        else if (m_sManageStep == "MgtPickData")
        {
            if (sMessage == ">>")
            {
                m_iDataPage++;
            }
            else if (sMessage == "<<")
            {
                m_iDataPage--;
            }
            else
            {
                m_sDataCard = sMessage;
                llMessageLinked(LINK_THIS, 0, "Load Card", m_sDataCard);
                return;
            }
            llMessageLinked(LINK_THIS, 0, "Load Data", sMessage);
            m_sManageStep = "MgtStart";
            DisplayMenu(keyDlg, "MenuManage");
            // Done
        }
        else if (sMessage == "Done")
        {
            ClearMgr();
            llRegionSayTo(keyDlg, 0, sGetRaceStatus(keyDlg));
            if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
            {
                ReportMemory(keyDlg);
                llMessageLinked(LINK_THIS, 0, "ReportMemory", (string)keyDlg);
            }
        }
        return;
    }

    if (sMessage == "Cancel" || sMessage == "OK")
        return;
    m_keyRiderDlg = keyDlg;
    ClearMgr();
    LoadRiderData(m_keyRiderDlg, sUserName);
    integer bRegistered;
    if (sGetRiderEntry(m_keyRiderDlg) != "")
        bRegistered = TRUE;

    if (sMessage == "Done" || sMessage == "See My Data")
    {
        // Done || See My Data
        PresentRiderData();
        m_sRiderStep = " ";
        sUpdateRiderEntry(m_keyRiderDlg);
        DisplayMenu(m_keyRiderDlg, "MenuComplete");
        // Show Data - Special - Thais only
    }
    else if (sMessage == "Show Data")
    {
        sGetRaceStatus(keyDlg);
        llMessageLinked(LINK_THIS, 0, "Show Data", m_sRiderDataList);
        m_sRiderStep = " ";
        DisplayMenu(m_keyRiderDlg, "MenuComplete");
    }
    else if (m_sRiderStep == "Startup")
    {
        // Add Entry
        if (m_sRiderLeague == "")
        {
            // If user is new then add a new rider entry
            m_sRiderLeague = sMessage;
            m_sRiderStep = "Team";
            sUpdateRiderEntry(m_keyRiderDlg);
            DisplayMenu(m_keyRiderDlg, "MenuTeam");
            // Continue Entry
        }
        else
        {
            // Otherwise load the user's rider entry
            m_sRiderStep = "Startup";
            DisplayMenu(m_keyRiderDlg, "MenuStartup");
        }
    }
    else if (m_sRiderStep == "Team")
    {
        // Add Team
        sMessage = sRemoveCRs(sMessage);
        m_sRiderTeam = sMessage;
        m_sRiderStep = "AddDiv";
        sUpdateRiderEntry(m_keyRiderDlg);
        DisplayMenu(m_keyRiderDlg, "MenuAddDiv");
    }
    else if (m_sRiderStep == "AddDiv")
    {
        // Add Div
        if (sMessage == "Div 1")
        {
            m_sRiderStep = "AddName1";
        }
        else if (sMessage == "Div 2")
        {
            m_sRiderStep = "AddName2";
        }
        else if (sMessage == "Div 3")
        {
            m_sRiderStep = "AddName3";
        }
        else if (sMessage == "Open")
        {
            m_sRiderStep = "AddName4";
        }
        else if (sMessage == "Bloodbath-D2")
        {
            m_sRiderStep = "AddName5";
        }
        sUpdateRiderEntry(m_keyRiderDlg);
        DisplayMenu(m_keyRiderDlg, "MenuAddName");
    }
    else if (llSubStringIndex(m_sRiderStep, "AddName") >= 0)
    {
        // Add Tharl Name
        sMessage = sRemoveCRs(sMessage);
        if (sMessage == "")
        {
            DisplayMenu(m_keyRiderDlg, "MenuAddName");
            return;
        }
        else if (m_sRiderStep == "AddName1")
        {
            m_sTharl1 = sMessage;
        }
        else if (m_sRiderStep == "AddName2")
        {
            m_sTharl2 = sMessage;
        }
        else if (m_sRiderStep == "AddName3")
        {
            m_sTharl3 = sMessage;
        }
        else if (m_sRiderStep == "AddName4")
        {
            m_sTharl4 = sMessage;
        }
        else if (m_sRiderStep == "AddName5")
        {
            m_sTharl5 = sMessage;
        }

        // Mark already selected buttons with "-"
        string sButtons;
        sButtons = sAddMarker(m_sTharl1, sButtons);
        sButtons = sAddMarker(m_sTharl2, sButtons);
        sButtons = sAddMarker(m_sTharl3, sButtons);
        sButtons = sAddMarker(m_sTharl4, sButtons);
        sButtons = sAddMarker(m_sTharl5, sButtons);
        string sCommand = "MenuAddDiv" + sButtons;

        // Repeat Add Div
        m_sRiderStep = "AddDiv";
        sUpdateRiderEntry(m_keyRiderDlg);
        DisplayMenu(m_keyRiderDlg, "MenuAddDiv" + sButtons);
    }
    else if (sMessage == "Change Data")
    {
        // Change Data
        RemoveRiderEntry(m_keyRiderDlg);
        m_sRiderStep = "Startup";
        DisplayMenu(m_keyRiderDlg, "MenuStartup");
    }
    else if (sMessage == "Un-Register")
    {
        // Un-Register
        RemoveRiderEntry(m_keyRiderDlg);
        ClearRiderFields();
        sGetRaceStatus(m_keyRiderDlg);
        m_sRiderStep = " ";
        DisplayMenu(m_keyRiderDlg, "MenuDeleted");
    }
}
//==============================================================================
string sAddMarker(string sRider, string sButtons)
{
    if (sRider != "")
    {
        sButtons += "-";
    }
    else
    {
        sButtons += " ";
    }
    return sButtons;
}
//==============================================================================
// RemoveCRs: Truncate input before the first CR to remove multiple lines
//==============================================================================
string sRemoveCRs(string sMessage)
{
    integer iLoc = llSubStringIndex(sMessage, "\n");
    if (iLoc >= 0)
    {
        sMessage = llGetSubString(sMessage, 0, iLoc - 1);
    }
    return sMessage;
}
//==============================================================================
// Clear Mgr: Clear the manager permissions once in a rider dialog or done
//==============================================================================
ClearMgr()
{
    m_sKeyMgr = "";
    m_iIsManager = FALSE;
    llMessageLinked(LINK_THIS, FALSE, "m_iIsManager", "");
}
//==============================================================================
// EditRacer: Scratch or reset racer league.
//==============================================================================
EditRacer(string sPickRacer, string sPickEdit)
{
    // Get the entry for this rider from the database
    integer iBeg = llSubStringIndex(m_sRiderDataList, sPickRacer);
    string sRiderEntry;

    if (iBeg >= 0)
    {
        // Extract the entry
        if (iBeg < 70)
        {
            iBeg = 0; // From beg of data list
        }
        else
        {
            iBeg -= 70; // Back up 70 chars from display name
            string sRiderList = llGetSubString(m_sRiderDataList, iBeg, -1);
            iBeg = iBeg + llSubStringIndex(sRiderList, "|") + 1; // find "|"
        }
        string sSubDataList = llGetSubString(m_sRiderDataList, iBeg, -1);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        sRiderEntry = llGetSubString(m_sRiderDataList, iBeg, iEnd);
    }
    LoadRiderFields(sRiderEntry);

    if (sPickEdit == "Scratch")
    {
        RemoveRiderEntry(m_sKeyRider);
    }
    else if (llSubStringIndex(sPickEdit, "League") > 0)
    {
        string sLeague = sPickEdit;
        m_sRiderLeague = sLeague;
        sUpdateRiderEntry(m_sKeyRider);
    }
}
//==============================================================================
// Data Operations
//==============================================================================
// LoadRiderData: Load data from current avatar into single fields
//==============================================================================
LoadRiderData(string sKeyDlg, string sRiderLegacyName)
{
    // Get the entry for this rider from the database
    string sKeyRider = llGetSubString(sKeyDlg, 0, 7);
    string sRiderEntry = sGetRiderEntry(sKeyRider);

    // If not found, add a new startup entry for this rider and get entry
    if (sRiderEntry == "" && sRiderLegacyName != "")
    {
        sRiderEntry = sAddRiderEntry(sKeyDlg, sRiderLegacyName);
    }

    // Load the module fields
    LoadRiderFields(sRiderEntry);
}
//==============================================================================
// LoadRiderFields: Load data from current avatar into single fields
//==============================================================================
LoadRiderFields(string sRiderEntry)
{
    // Parse the entry and load the module fields
    list lstRiderData = llParseString2List(sRiderEntry, [","], ["|"]);

    // Get fields from data
    m_sKeyRider = llList2String(lstRiderData, 0);
    m_sRiderStep = llList2String(lstRiderData, 1);
    m_sRiderLegacyName = llList2String(lstRiderData, 2);
    m_sRiderDisplayName = llList2String(lstRiderData, 3);
    m_sRiderLeague = sGetField(lstRiderData, 4);
    m_sRiderTeam = sGetField(lstRiderData, 5);
    m_sTharl1 = sGetField(lstRiderData, 6);
    m_sTharl2 = sGetField(lstRiderData, 7);
    m_sTharl3 = sGetField(lstRiderData, 8);
    m_sTharl4 = sGetField(lstRiderData, 9);
    m_sTharl5 = sGetField(lstRiderData, 10);
}
//==============================================================================
// ClearRiderFields: Erase current rider data
//==============================================================================
ClearRiderFields()
{
    // Clear data fields
    m_sKeyRider = "";
    m_sRiderStep = "";
    m_sRiderLegacyName = "";
    m_sRiderDisplayName = "";
    m_sRiderLeague = "";
    m_sRiderTeam = "";
    m_sTharl1 = "";
    m_sTharl2 = "";
    m_sTharl3 = "";
    m_sTharl4 = "";
    m_sTharl5 = "";
}
//==============================================================================
// sGetField: Get a selected field from a list, trimmed
//==============================================================================
string sGetField(list lstRiderData, integer iFieldNo)
{
    // Get the entry for this rider from the database
    string sField = llList2String(lstRiderData, iFieldNo);
    sField = llStringTrim(sField, STRING_TRIM);
    return sField;
}
//==============================================================================
// sAddRiderEntry: Add a new data entry for a rider not in the database
// =============================================================================
string sAddRiderEntry(string sKeyDlg, string sRiderLegacyName)
{
    // Calculate unique dialog channel and display name
    sRiderLegacyName = sRemoveResident(sRiderLegacyName);
    m_sRiderDisplayName = sGetDisplayName(sKeyDlg);
    m_sRiderStep = "Startup";

    // Create initial data record containing key, channel, leg and disp names
    string sKeyRider = llGetSubString(sKeyDlg, 0, 7);
    string sRiderEntry = sKeyRider;
    sRiderEntry += "," + m_sRiderStep;
    sRiderEntry += "," + sRiderLegacyName;
    sRiderEntry += "," + m_sRiderDisplayName;
    sRiderEntry += ", , , , , , , |";

    // Append data record to the database and return it
    m_sRiderDataList += sRiderEntry;

    return sRiderEntry;
}
//==============================================================================
// Return Display name for keyID
//==============================================================================
string sGetDisplayName(key keyID)
{
    string sDisplayName = llGetDisplayName(keyID);

    // Remove "Resident"
    sDisplayName = sRemoveResident(sDisplayName);

    return (sDisplayName);
}
//==============================================================================
// Return Display name for keyID
//==============================================================================
string sRemoveResident(string sName)
{
    // Remove "Resident"
    integer iLoc = llSubStringIndex(sName, " Resident");
    if (iLoc > 0)
        sName = llGetSubString(sName, 0, iLoc - 1);

    return sName;
}
//==============================================================================
// sCreateRiderEntry: Create database record for current fields
// =============================================================================
string sUpdateRiderEntry(string sKeyRider)
{
    // Create initial data record containing key, channel, leg and disp names

    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    string sRiderEntry = sKeyRider;
    sRiderEntry = sAddField(sRiderEntry, m_sRiderStep);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderLegacyName);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderDisplayName);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderLeague);
    sRiderEntry = sAddField(sRiderEntry, m_sRiderTeam);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl1);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl2);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl3);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl4);
    sRiderEntry = sAddField(sRiderEntry, m_sTharl5);
    sRiderEntry += "|";

    ReplaceRiderEntry(sKeyRider, sRiderEntry);

    return sRiderEntry;
}
//==============================================================================
// sAddField: Append a new field to a data record, setting empties to a space
// =============================================================================
string sAddField(string sRecord, string sField)
{
    if (sField == "")
        sField = " ";
    sRecord += "," + sField;
    return sRecord;
}
//==============================================================================
// sGetRiderEntry: Locate and return the data for the selected rider
// If not found, return empty string
//==============================================================================
string sGetRiderEntry(string sKeyRider)
{
    // A data entry has 11 fields: (step is the registration stage for each racer)
    // "sKeyRider,sRiderStep,sSLName,sDispName,sLeague,sTeam,
    //  Tharl1,Tharl2,Tharl3,Tharl4,Tharl5|"

    // Find sKeyRider and the rest of the entry
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    integer iBeg = llSubStringIndex(m_sRiderDataList, sKeyRider);
    string sRiderEntry;

    if (iBeg >= 0)
    {
        // Extract the entry
        string sSubDataList = llGetSubString(m_sRiderDataList, iBeg, -1);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        sRiderEntry = llGetSubString(m_sRiderDataList, iBeg, iEnd);
    }
    return sRiderEntry;
}
//==============================================================================
// ReplaceRiderEntry: Remove old entry and append the new entry
// =============================================================================
ReplaceRiderEntry(string sKeyRider, string sRiderEntry)
{
    // Remove existing entry for rider
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    RemoveRiderEntry(sKeyRider);

    // Append new entry to end of list
    m_sRiderDataList += sRiderEntry;
}
//==============================================================================
// RemoveRiderEntry: Remove existing rider record from the database
// =============================================================================
RemoveRiderEntry(string sKeyRider)
{
    // Find sKeyTharl and remove racer data
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    integer iBeg = llSubStringIndex(m_sRiderDataList, sKeyRider);
    if (iBeg >= 0)
    {
        string sSubDataList = llGetSubString(m_sRiderDataList, iBeg, -1);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        m_sRiderDataList = llDeleteSubString(m_sRiderDataList, iBeg, iEnd);
    }
}
//==============================================================================
// DebugSay(): llOwnerSay if in debug mode
// =============================================================================
DebugSay(string sMsg)
{
    if (m_bDebug)
        llOwnerSay("[SignupData] " + sMsg);
}
// =============================================================================
// Event List
// =============================================================================
default
{
    // =========================================================================
    state_entry()
    {
        m_iDialogChannel = (integer)llFrand(DEBUG_CHANNEL) * -1;
        m_iNLeagues = 4;
        InitializeForm();
        ReportMemory("");
    }
    // =========================================================================
    on_rez(integer iNum)
    {
        llResetScript();
    }
    // =========================================================================
    touch_start(integer iNTouch)
    {

        // Test: Insert a name for symbol checking
        key keyDlg = llDetectedKey(0);
        string sRiderLegacyName = llDetectedName(0);

        // Refresh m_iDialogChannel
        llMessageLinked(LINK_THIS, m_iDialogChannel, "m_iDialogChannel", "");

        // See if user is a manager
        CheckManager(sRiderLegacyName);

        // Display the startup menu
        string sRiderEntry = sGetRiderEntry(keyDlg);
        if (sRiderEntry != "")
        {
            LoadRiderData(keyDlg, sRiderLegacyName);
            DisplayMenu(keyDlg, "MenuStartupReg"); // Already registered
        }
        else
        {
            DisplayMenu(keyDlg, "MenuStartup");
        }

        return;
    }
    //======================================
    listen(integer iChannel, string sUserName, key keyID, string sMessage)
    {
        // DebugSay("listen: iChannel=" + (string)iChannel);
        // DebugSay("listen: sMessage=" + sMessage);
        //  Monitor dialog channel
        if (iChannel == m_iDialogChannel)
        {
            CheckManager(sUserName);
            DialogResponse(keyID, sUserName, sMessage);
        }
    }
    //======================================
    link_message(integer iSender, integer iNum, string sCommand, key keyID)
    {

        string sText = (string)keyID;
        key keyDlg = keyID;

        if (sCommand == "m_sTrackName")
        {
            m_sTrackName = sText;
        }
        else if (sCommand == "m_sRaceDate")
        {
            m_sRaceDate = sText;
        }
        else if (sCommand == "m_sRaceTime")
        {
            m_sRaceTime = sText;
        }
        else if (sCommand == "m_iNLeagues")
        {
            m_iNLeagues = iNum;
        }
        else if (sCommand == "m_sRiderDataList")
        {
            m_sRiderDataList = sText;
        }
        else if (sCommand == "EndOfData")
        {
            m_sManageStep = "MgtStart";
            m_sKeyMgr = keyID;
            m_sMgrName = llGetDisplayName(m_sKeyMgr);
            DisplayMenu(keyDlg, "MenuManage");
        }
    }
    //=============================================
    dataserver(key keyRequested, string sData)
    {
        // Store number of lines and request first line of card
        if (keyRequested == m_keyNumberOfLinesReq)
        {
            m_iTotalNCLines = (integer)sData;
            m_keyLineReadRequest =
                llGetNotecardLine(m_sManagerCard, m_iNCLineNumber);
            return;
        }

        // Ignore if not a card line
        if (keyRequested != m_keyLineReadRequest)
        {
            return;
        }

        m_sStatus = sData;
        if (m_sStatus == EOF)
        {
            return;
        }

        // Request another line
        m_keyLineReadRequest = llGetNotecardLine(m_sManagerCard, ++m_iNCLineNumber);

        // Process the line we already got
        string sLine = llStringTrim(sData, STRING_TRIM);
        ParseNotecardLine(sLine);
    }
    //=============================================
    timer()
    {
        // Clear the listeners after 5 minutes silence
        if (m_iDialogCounter > 0)
        {
            if (--m_iDialogCounter == 0)
            {
                CloseMenu();
            }
        }
    }
    // =========================================================================
}
// =============================================================================
