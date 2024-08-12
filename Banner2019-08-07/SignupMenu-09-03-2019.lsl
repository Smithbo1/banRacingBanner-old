// =============================================================================
// TharlGate: TGSignupMenu.lsl
// TGSignup: Register riders for a race - Menu Operations
// TharlGate, All rights reserved; Copyright 2016-2019; LauraTarnsman Resident
// Work in Progress:
// 1. Fix manage Edit Data button
// 3. Make Load Data button scan for available notecards
// 6. Create Show Data outside of manage menu
// ============================== Upd 08-07-2019 AM ============================
// Configuration
string m_csVersion = "2019.09.03";
integer m_bDebug = FALSE;
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";

// Manage Race
string m_sRaceStatus; // Set by linked message from SignupData
integer m_iNLeagues;  // Set by linked message from SignupData
integer m_iIsManager; // Set by linked message from SignupData
integer m_iRegistrationOpen;
string m_sPickRacer;
string m_sTrackName;
string m_sRaceDate;
string m_sRaceTime;
integer m_iNEntries;

// Rider Database
string m_sRiderDataList; // Set by linked message from SignupData
integer m_iRacerPage;    // Current page of manager Pick Racer dialog

// Current Rider Fields
string m_sKeyRider;
string m_sRiderStep;
string m_sRiderLegacyName;
string m_sRiderDisplayName;
string m_sRiderLeague;
string m_sRiderTeam;
string m_sRiderTharl1;
string m_sRiderTharl2;
string m_sRiderTharl3;
string m_sRiderTharl4;
string m_sRiderTharl5;
string m_sRiderName;

// Comm
integer m_iDialogChannel; // Set by linked message from SignupData
key m_keyDlg;

// Note Card
key m_keyNumberOfLinesReq;
key m_keyLineReadRequest;
integer m_iTotalNCLines;
integer m_iNCLineNumber;
string m_sStatus;
string m_sDataCard;

//==============================================================================
// ReportMemory: Show version and free memory
//==============================================================================
ReportMemory(key keyDlg)
{
    string sText = "SignupMenus: Ver. " + m_csVersion +
                   " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
        llRegionSayTo(keyDlg, 0, sText);
    else
        llSay(0, sText);
}
//==============================================================================
// MenuStartup: Startup Menu
//==============================================================================
MenuStartup(key keyDlg, integer bRegistered)
{
    list lstControlButtons = [];
    string sDialogMessage = m_sRaceStatus + "\n";
    string sBottomLeague;
    string sManage = "-";
    string sShow = "-";
    string sLeagues;
    string sALeague = "A League";
    string sBLeague = "B League";
    string sCLeague = "C League";
    string sDLeague = "D League";

    // Set League Selections from m_iNLeagues set from Linked Message
    if (m_iNLeagues == 1)
    {
        sLeagues = "";
        sBottomLeague = "";
    }
    else if (m_iNLeagues == 2)
    {
        sLeagues = "A or B";
        sCLeague = "-";
        sDLeague = "-";
        sBottomLeague = "B";
    }
    else if (m_iNLeagues == 3)
    {
        sLeagues = "A, B, or C";
        sDLeague = "-";
        sBottomLeague = "C";
    }
    else if (m_iNLeagues == 4)
    {
        sLeagues = "A, B, C, or D";
        sBottomLeague = "D";
    }
    if (m_iIsManager)
        sManage = "Manage";
    if (keyDlg == m_sThaisKey)
        sShow = "Show Data";

    if (m_iRegistrationOpen)
    {
        if (bRegistered)
        {
            lstControlButtons += [
                sShow, "Close", sManage,
                "See My Data", "Change Data", "Un-Register"
            ];
            sDialogMessage +=
                "\nYou are already registered for the race.\n\n" +
                "See My Data: Send race signup data to chat.\n" +
                "Change Data: Re-register with different information.\n" +
                "Un-Register: Un-register from the race.\n" +
                "Close: Close the menu without making any changes.\n";
        }
        else
        {
            sDialogMessage += "Select your racing league: " +
                              sLeagues + ".\n\nRegister for your assigned league. " +
                              "If you are not assigned to a league, choose league " +
                              sBottomLeague + ".\n" +
                              "Close: Close menu without creating an entry.\n";
            lstControlButtons = [
                sDLeague, "Close", sManage,
                sALeague, sBLeague,
                sCLeague
            ];
            if (keyDlg == m_sThaisKey)
            {
                lstControlButtons = [
                    sDLeague, sShow, sManage,
                    sALeague, sBLeague,
                    sCLeague
                ];
            }
        }
    }
    else
    {
        if (m_iIsManager)
        {
            lstControlButtons = [sManage];
        }
    }
    if (m_iIsManager)
    {
        sDialogMessage += "Manage: View the Race Director's menu.";
    }

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuManage: Management options
//==============================================================================
MenuManage(key keyDlg)
{
    string sLoadData = "-";
    string sNLeagues = "-";
    string sSaveData = "-";

    if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
    {
        sLoadData = "Load Data";
        sNLeagues = "Set # Lgs";
        sSaveData = "Save Data";
    }
    list lstControlButtons = [
        sLoadData, "Done", sSaveData,
        "Race Form", "Combined Fm", sNLeagues,
        "Open Reg", "Close Reg", "Edit Racer",
        "New Race", "Clear Data", "Show Data"
    ];
    string sDialogMessage = m_sRaceStatus + "\n";
    sDialogMessage += "Manage Race Setup\n\n" +
                      "1. New Race: Clear data and set up new race.\n" +
                      "2. Clear Data: Erase all rider entries.\n" +
                      "3. Show Data: Show data entered so far.\n" +
                      "4. Open Reg: Open registration.\n" +
                      "5. Close Reg: Close registration.\n" +
                      "6. Edit Racer: Scratch or change league.\n" +
                      "7. Race Form: Randomize, send race form to chat.\n" +
                      "8. Combined Fm: Race form with leagues combined.";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuRaceDate: Enter date of race
//==============================================================================
MenuRaceDate(key keyDlg)
{
    string sDialogMessage =
        "\nRace Date: Please enter the date of the race.\n\n" +
        "Example: Saturday, Jan 1, 2017";

    // Display the dialog
    OpenInput(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuRaceTime: Enter time of race
//==============================================================================
MenuRaceTime(key keyDlg)
{
    string sDialogMessage =
        "\nRace Date: Please enter the time of the race.\n\n" +
        "Example: 8 AM SL";

    // Display the dialog
    OpenInput(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuSetLgs: Set the number of Leagues: 1, 2, 3, or 4
//==============================================================================
MenuNumLgs(key keyDlg)
{
    list lstControlButtons = [
        "4", "-", "Cancel",
        "1", "2", "3"
    ];
    string sDialogMessage =
        "\nNumber of leagues: Select the number of leagues to register.\n\n" +
        "Example: 4 would be Leagues A, B, C, and D";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuConfirmClear: Confirm clearing all data
//==============================================================================
MenuConfirmClear(key keyDlg)
{
    list lstControlButtons = [
        "Clear Data!", "Cancel"
    ];
    string sDialogMessage = "\nClear Data\n\n" +
                            "Confirm that you want to erase all registration data.\n";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================
// MenuPickData: Choose Data File
//==============================================================================
MenuPickData(key keyDlg)
{
    list lstControlButtons = [ "-", "Close", "-" ];
    string sDialogMessage = " Select Data Card:\n";
    integer iNItems = llGetInventoryNumber(INVENTORY_NOTECARD);

    string sNoteCardList;
    integer iCount;
    integer iCard;

    for (iCount = 0; iCount < iNItems; iCount++)
    {
        string sCardName = llGetInventoryName(INVENTORY_NOTECARD, iCount);
        if (sCardName != "ManagerList")
        {
            sNoteCardList += sCardName + "|";
        }
    }
    list lstDataCards = llParseString2List(sNoteCardList, ["|"], []);
    iNItems = llGetListLength(lstDataCards);

    lstControlButtons += lstDataCards;

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================
// MenuTeam: Prompt user for Team representing
//==============================================================================
MenuTeam(key keyDlg)
{
    string sDialogMessage =
        "\nTeam: Please enter the team you are representing " +
        "and click \"Submit\".\n" +
        "If you are not riding for a team, you may leave this blank " +
        "and click \"Submit\".";

    // Display the dialog
    OpenInput(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuAddDiv: Prompt user to select a Div to add a tharl
//==============================================================================
MenuAddDiv(key keyDlg, string sButtons)
{
    list lstControlButtons;

    string sBtn1 = "Div 1";
    string sBtn2 = "Div 2";
    string sBtn3 = "Div 3";
    string sBtn4 = "Open";
    string sBtn5 = "Bloodbath-D2";
    string sBtn6 = "Done";

    // Disable buttons for divisions already selected
    if (llGetSubString(sButtons, 0, 0) == "-")
        sBtn1 = "-";
    if (llGetSubString(sButtons, 1, 1) == "-")
        sBtn2 = "-";
    if (llGetSubString(sButtons, 2, 2) == "-")
        sBtn3 = "-";
    if (llGetSubString(sButtons, 3, 3) == "-")
        sBtn4 = "-";
    if (llGetSubString(sButtons, 4, 4) == "-")
        sBtn5 = "-";

    lstControlButtons = [sBtn4] + [sBtn5] + [sBtn6] +
                        [sBtn1] + [sBtn2] + [sBtn3];

    string sDialogMessage = "\nDivision: Please select the division to add:\n" +
                            "Div 1: 3 to 12 points.\n" +
                            "Div 2: 13 to 15 points.\n" +
                            "Div 3: 16 to 18 points.\n" +
                            "Open: 19 to 23 points.\n" +
                            "Bloodbath: Div 2 - Register to enter Bloodbath race.\n" +
                            "Select \"Done\" if you have no more entries";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuAddName: Prompt user for Tharl Name
//==============================================================================
MenuAddName(key keyDlg)
{
    string sDialogMessage =
        "\nTharl Name: Please enter the name of the Tharlarion.";

    // Display the dialog
    OpenInput(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuComplete: Finalize new data
//==============================================================================
MenuComplete(key keyDlg)
{
    string sDialogMessage = "\nYour registration has been submitted.\n\n" +
                            "Review your information in the chat window and confirm " +
                            "that it is correct.\n\n" +
                            "If it is not, click the banner and select \"Change Entry\", and " +
                            "re-enter your information.";
    sDialogMessage += "\n\n" +
                      "Be sure your tag and your tharls are set to " +
                      "\"Tharl Racers of Gor\" at race time, and have a great race!";

    DialogSay(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuComplete: Finalize new data
//==============================================================================
MenuDeleted(key keyDlg)
{
    string sDialogMessage = "\nYour registration has been deleted.\n\n" +
                            "You may re-register for this race at any time.";

    DialogSay(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuPickRacer: Select Racer to edit data
//==============================================================================
MenuPickRacer(key keyDlg)
{

    list lstControlButtons;

    lstControlButtons = [ "<<", "Close", ">>", "Tom", "Dick", "Harry", "John" ];

    string sDialogMessage = "Edit Racer allows you to reset the League " +
                            "or scratch the racer from the raceday.\n\n" +
                            "Select the racer to edit from the buttons shown.\n" +
                            ">> and << goes to next and previous listings.\n" +
                            "Close will cancel the edit.";

    string sRacerList = sRacerButtonList();
    lstControlButtons = llParseString2List(sRacerList, ["|"], []);

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// RacerButtonList: Get a list of buttons for each racer.
//==============================================================================
string sRacerButtonList()
{
    string sRacerList;

    list lstRacers = llParseString2List(m_sRiderDataList, ["|"], []);
    integer iNEntries = llGetListLength(lstRacers);
    integer iEntry;
    integer iBegEntry = m_iRacerPage * 9;
    integer iEndEntry = iBegEntry + 8;

    string sPrev = "<<";
    string sNext = ">>";
    if (iBegEntry == 0)
        sPrev = "-";
    if (iNEntries < iEndEntry + 2)
        sNext = "-";
    sRacerList = sPrev + "|Close|" + sNext + "|";

    for (iEntry = iBegEntry; iEntry <= iEndEntry; iEntry++)
    {
        string sRacerData = llList2String(lstRacers, iEntry);

        list lstFields = llParseString2List(sRacerData, [","], []);
        if (iEntry < iNEntries)
        {
            string sName = llList2String(lstFields, 3);
            if (sName == "")
                sName = llList2String(lstFields, 2);
            sName = llGetSubString(sName, 0, 9);
            sRacerList += sName + "|";
        }
    }
    return sRacerList;
}
//==============================================================================
// MenuPickEdit: Select edit to apply: Scratch or pick league
//==============================================================================
MenuPickEdit(key keyDlg)
{
    list lstControlButtons;

    lstControlButtons = [ "D League", "Scratch", "Cancel",
                          "A League", "B League", "C League" ];

    string sDialogMessage = "Select edit choice.\n\n" +
                            "1. Reset to specified league.\n" +
                            "2. Scratch from all races.\n" +
                            "3. Cancel the edit and return to menu.";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// DialogSay: Present a dropdown with message and "OK"
//==============================================================================
DialogSay(key keyDlg, string sMessage)
{
    list lstControlButtons = [];

    // Display the dialog
    OpenMenu(keyDlg, sMessage, lstControlButtons);
}
//==============================================================================
// OpenMenu: Get a dialog channel and open a dialog
//==============================================================================
OpenMenu(key keyDlg, string sDialogMessage, list lstControlButtons)
{
    llDialog(keyDlg, sDialogMessage, lstControlButtons, m_iDialogChannel);
}
//==============================================================================
// OpenInput: Get a dialog channel and open a text input
//==============================================================================
OpenInput(key keyDlg, string sDialogMessage)
{
    llTextBox(keyDlg, sDialogMessage, m_iDialogChannel);
}
//==============================================================================
// Load Race Data
//==============================================================================
// LoadRaceData: Load a data note card into m_sRiderDataList
//==============================================================================
LoadRaceData()
{
    // Set up dataserver to load note card
    m_iNCLineNumber = 0;
    m_sRiderDataList = "";
    m_keyNumberOfLinesReq = llGetNumberOfNotecardLines(m_sDataCard);
}
//==============================================================================
// ParseNotecardLine: Add name to manager list
//==============================================================================
ParseNotecardLine(string sLine)
{
    integer iDataIndex = llSubStringIndex(sLine, "#%");

    if (iDataIndex < 0)
    {
        // Do nothing: An extraneous chat line was inserted
    }
    else if (llSubStringIndex(sLine, "BeginData") >= 0)
    {
        // Do nothing: Data begins on next line
    }
    else if (llSubStringIndex(sLine, "EndOfData") >= 0)
    {
        // Send all collected data
        TransferRaceData();
    }
    else if (llSubStringIndex(sLine, "#%TrackName") >= 0)
    {
        // Trackname at index + 12
        m_sTrackName = sOffsetLine(sLine, iDataIndex + 12);
    }
    else if (llSubStringIndex(sLine, "#%RaceDate") >= 0)
    {
        // RaceDate at index + 11
        m_sRaceDate = sOffsetLine(sLine, iDataIndex + 11);
    }
    else if (llSubStringIndex(sLine, "#%RaceTime") >= 0)
    {
        // RaceTime at index + 11
        m_sRaceTime = sOffsetLine(sLine, iDataIndex + 11);
    }
    else if (llSubStringIndex(sLine, "#%NLeagues") >= 0)
    {
        // NLeagues at index + 11
        m_iNLeagues = (integer)sOffsetLine(sLine, iDataIndex + 11);
    }
    else
    {
        // Racer data entry at index + 2
        m_sRiderDataList += sOffsetLine(sLine, iDataIndex + 2);
    }
}
//==============================================================================
// sOffsetLine: Return remainder of line after iOffset characters
// This removes the chat header from each line.
//==============================================================================
string sOffsetLine(string sLine, integer iOffset)
{
    sLine = llGetSubString(sLine, iOffset, -1);
    return sLine;
}
//==============================================================================
// SaveData: Send race data to local chat
//==============================================================================
SaveData()
{
    // Extract racer entries and get number of entries
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    m_iNEntries = llGetListLength(lstEntries);

    // For each racer, send a data line
    string sLine;
    integer iCount;

    llRegionSayTo(m_keyDlg, 0, "#%" + "========= BeginData =========");
    llRegionSayTo(m_keyDlg, 0, "#%TrackName " + m_sTrackName);
    llRegionSayTo(m_keyDlg, 0, "#%RaceDate " + m_sRaceDate);
    llRegionSayTo(m_keyDlg, 0, "#%RaceTime " + m_sRaceTime);
    llRegionSayTo(m_keyDlg, 0, "#%NLeagues " + (string)m_iNLeagues);

    for (iCount = 0; iCount < m_iNEntries; ++iCount)
    {
        string sRiderEntry = llList2String(lstEntries, iCount);
        llRegionSayTo(m_keyDlg, 0, "#%" + sRiderEntry + "|");
    }
    llRegionSayTo(m_keyDlg, 0, "#%" + "========= EndOfData =========");

    llMessageLinked(LINK_THIS, 0, "Show Data", m_sRiderDataList);

    //    if (m_keyDlg == m_sThaisKey || m_keyDlg == m_sKylieKey) {
    //        ReportMemory(m_keyDlg);
    //    }
    //    llResetScript();
}
//==============================================================================
// sGetRaceName: Display race time and date
//==============================================================================
string sGetRaceName()
{
    string sLeagues = "A League.";
    if (m_iNLeagues == 2)
    {
        sLeagues = "A and B Leagues.";
    }
    else if (m_iNLeagues == 3)
    {
        sLeagues = "A, B, and C Leagues.";
    }
    else if (m_iNLeagues == 4)
    {
        sLeagues = "A, B, C, and D Leagues.";
    }
    string sRaceName = m_sTrackName +
                       " on " + m_sRaceDate + " at " + m_sRaceTime +
                       " with " + (string)m_iNEntries + " racers.\n" +
                       "Racing " + sLeagues;
    return sRaceName;
}
//==============================================================================
// TransferRaceData: Send race data to the Signup script
//==============================================================================
TransferRaceData()
{
    llMessageLinked(LINK_THIS, 0, "m_sTrackName", m_sTrackName);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDate", m_sRaceDate);
    llMessageLinked(LINK_THIS, 0, "m_sRaceTime", m_sRaceTime);
    llMessageLinked(LINK_THIS, m_iNLeagues, "m_iNLeagues", "");
    llMessageLinked(LINK_THIS, 0, "m_sRiderDataList", m_sRiderDataList);
    llMessageLinked(LINK_THIS, 0, "EndOfData", m_keyDlg);
}
//==============================================================================
// DebugSay(): llOwnerSay if in debug mode
// =============================================================================
DebugSay(string sMsg)
{
    if (m_bDebug)
        llOwnerSay("[SignupMenu] " + sMsg);
}
//==============================================================================
// Event List
// =============================================================================
default
{
    // =========================================================================
    state_entry()
    {
        ReportMemory("");
    }
    // =========================================================================
    on_rez(integer iNum)
    {
        llResetScript();
    }
    //======================================
    link_message(integer iSender, integer iNum, string sCommand, key keyID)
    {

        string sText = (string)keyID;
        key keyDlg = keyID;
        // DebugSay("link_message: sCommand/sText=" + sCommand + "/" + sText);

        // Operation Calls
        if (sCommand == "ReportMemory")
        {
            ReportMemory(keyDlg);
        }
        else if (sCommand == "Save Data")
        {
            m_sRiderDataList = sText;
            SaveData();
        }
        else if (sCommand == "Load Card")
        {
            m_sDataCard = sText;
            LoadRaceData();
            // Data Settings
        }
        else if (sCommand == "m_iDialogChannel")
        {
            m_iDialogChannel = iNum;
        }
        else if (sCommand == "m_sTrackName")
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
        else if (sCommand == "m_keyDlg")
        {
            m_keyDlg = keyID;
        }
        else if (sCommand == "m_iIsManager")
        {
            m_iIsManager = iNum;
        }
        else if (sCommand == "m_iRegistrationOpen")
        {
            m_iRegistrationOpen = iNum;
        }
        else if (sCommand == "m_sRaceStatus")
        {
            m_sRaceStatus = sText;
        }
        else if (sCommand == "m_sRiderDataList")
        {
            m_sRiderDataList = sText;
        }
        else if (sCommand == "m_iRacerPage")
        {
            m_iRacerPage = iNum;
        }
        else if (sCommand == "m_sPickRacer")
        {
            m_sPickRacer = sText;
            MenuPickEdit(m_keyDlg);
            // Menu Calls
        }
        else if (sCommand == "MenuStartup")
        {
            MenuStartup(keyDlg, FALSE);
        }
        else if (sCommand == "MenuStartupReg")
        {
            MenuStartup(keyDlg, TRUE);
        }
        else if (sCommand == "MenuManage")
        {
            MenuManage(keyDlg);
        }
        else if (sCommand == "MenuConfirmClear")
        {
            MenuConfirmClear(keyDlg);
        }
        else if (sCommand == "DialogSayClearing")
        {
            DialogSay(keyDlg, "Clearing race data and resetting script.");
        }
        else if (sCommand == "MenuRaceDate")
        {
            MenuRaceDate(keyDlg);
        }
        else if (sCommand == "MenuRaceTime")
        {
            MenuRaceTime(keyDlg);
        }
        else if (sCommand == "MenuNumLgs")
        {
            MenuNumLgs(keyDlg);
        }
        else if (sCommand == "MenuComplete")
        {
            MenuComplete(keyDlg);
        }
        else if (sCommand == "MenuDeleted")
        {
            MenuDeleted(keyDlg);
        }
        else if (sCommand == "MenuTeam")
        {
            MenuTeam(keyDlg);
        }
        else if (sCommand == "MenuPickRacer")
        {
            MenuPickRacer(keyDlg);
        }
        else if (sCommand == "MenuPickEdit")
        {
            MenuPickEdit(keyDlg);
        }
        else if (llSubStringIndex(sCommand, "MenuAddDiv") == 0)
        {
            string sButtons = llGetSubString(sCommand, 10, -1);
            MenuAddDiv(keyDlg, sButtons);
        }
        else if (sCommand == "MenuAddName")
        {
            MenuAddName(keyDlg);
        }
        else if (sCommand == "MenuPickData")
        {
            MenuPickData(keyDlg);
        }
    }
    //=============================================
    dataserver(key keyRequested, string sData)
    {
        // DebugSay("dataserver sData=" + sData);
        //  Store number of lines and request first line of card
        if (keyRequested == m_keyNumberOfLinesReq)
        {
            m_iTotalNCLines = (integer)sData;
            m_keyLineReadRequest =
                llGetNotecardLine(m_sDataCard, m_iNCLineNumber);
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
        m_keyLineReadRequest = llGetNotecardLine(m_sDataCard, ++m_iNCLineNumber);

        // Process the line we already got
        string sLine = llStringTrim(sData, STRING_TRIM);
        ParseNotecardLine(sLine);
    }
    // =========================================================================
}
// =============================================================================
 