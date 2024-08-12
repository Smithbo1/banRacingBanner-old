// =============================================================================
// TharlGate: bnrSignupMenu.lsl
// bnrSignupMenu: Register riders for a race - Menu Operations
// TharlGate, All rights reserved; Copyright 2016-2024; LauraTarnsman Resident
// ============================== Upd 2024-08-12 ============================
// Configuration
string m_csVersion = "bnrSignupMenu (2024-08-12)";
integer m_bDebug = FALSE;
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";
string m_sHipsKey = "04860cbf-8442-422b-872c-8c2961e86437";
string m_sMyPrefix = "m-";

// Manage Race
string m_sRaceStatus;    // Set by linked message from SignupData
integer m_iNLeagues = 4; // Set by linked message from SignupData
string m_sManagerList;   // List of managers
integer m_bIsManager;    // Set from manager list
integer m_bRegistrationOpen;
string m_sPickRacer;
string m_sTrackName;
string m_sRaceDate;
string m_sRaceTime;
string m_sRaceDayTime;
string m_sNextRaceDayTime;
string m_sNextRaceDate;
string m_sNextRaceTime;

// Rider Database
string m_sRiderDataList; // Set by linked message from SignupData
integer m_iRacerPage;    // Current page of manager Pick Racer dialog

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
// MenuStartup: Startup Menu
//==============================================================================
MenuStartup(key keyDlg, integer bRegistered)
{
    list lstControlButtons = [];
    string sDialogMessage;
    string sBottomLeague;
    string sManage = "-";
    string sShow = "-";
    string sSaveData = "-";
    string sLeagues;
    string sALeague = "A League";
    string sBLeague = "B League";
    string sCLeague = "C League";
    string sDLeague = "D League";
    string m_sMyPrefix = "m-";

    SendLnkCmd("h-SetNextRaceDay", "", 0); // Set date in case of "new race"
    SetRaceStatus();

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
    // Add Show Data
    if (m_bIsManager)
    {
        sShow = "Show Data";
        sManage = "Manage";
    }
    // Add Save Data
    if (keyDlg == m_sThaisKey)
    {
        sSaveData = "Save Data";
    }

    // Begin dialog message
    if (m_sRaceStatus != "")
    {
        sDialogMessage = m_sRaceStatus + "\n";
    }

    if (m_bRegistrationOpen)
    {
        // Registration Open mode
        if (bRegistered)
        {
            // Already registered
            lstControlButtons += [
                sShow, "Close", sManage,
                "See My Data", "Change Data", "Un-Register"
            ];
            if (keyDlg == m_sThaisKey)
            {
                lstControlButtons = [ "-", sSaveData, "-" ] + lstControlButtons;
            }
            sDialogMessage +=
                "\nYou are already registered for the race.\n\n" +
                "See My Data: Send race signup data to chat.\n" +
                "Change Data: Re-register with different information.\n" +
                "Un-Register: Un-register from the race.\n" +
                "Close: Close the menu without making any changes.\n";
        }
        else
        {
            // New Registration
            sDialogMessage += "Select your racing league: " +
                              sLeagues + ".\n\nRegister for your assigned league. " +
                              "If you are not assigned to a league, choose league " +
                              sBottomLeague + ".\n" +
                              "Close: Close menu without creating an entry.\n";
            if (m_bIsManager)
            {
                lstControlButtons += [ "Manage", "Show Data", sSaveData ];
            }
            lstControlButtons += [
                sDLeague, "Close", "-",
                sALeague, sBLeague,
                sCLeague
            ];
        }
    }
    else
    {
        // Registration not open
        if (m_bIsManager)
        {
            lstControlButtons = [ sManage, sShow, sSaveData ];
        }
    }
    if (m_bIsManager)
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
    string sCombined = "-";
    string sShowRcovr = "-";

    m_keyDlg = keyDlg; // Preserve for external calls (load data card)

    if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
    {
        sLoadData = "Load Data";
        sSaveData = "Save Data";
        sNLeagues = "Set # Lgs";
        sCombined = "Combined Fm";
        sNLeagues = "-";
        sCombined = "-";
        sShowRcovr = "ShowRcovr";
    }
    list lstControlButtons = [
        sLoadData, "Done", sSaveData,
        "Race Form", sCombined, sNLeagues,
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
                      "7. Race Form: Randomize, send race form to chat.\n";

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
    string sDialogMessage =
        "\nClear Data\n\n" +
        "Confirm that you want to erase all registration data.\n";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuConfirmNew: Confirm clearing all data for new race
//==============================================================================
MenuConfirmNew(key keyDlg)
{
    list lstControlButtons = [
        "New Race!", "Cancel"
    ];
    string sDialogMessage =
        "\nNew Race\n\n" +
        "Confirm that you want to erase all registration data\n" +
        "and open a new race.\n";

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// MenuPickData: Choose Data File
//==============================================================================
MenuPickData(key keyDlg)
{
    list lstControlButtons = [ "Recover", "Close", "ShowRcovr" ];
    string sDialogMessage = " Select Data Card:\n";
    integer iNItems = llGetInventoryNumber(INVENTORY_NOTECARD);

    string sNoteCardList;
    integer iCount;
    integer iCard;

    DebugTrace("MenuPickData: " + (string)iNItems + " items");
    for (iCount = 0; iCount < iNItems; iCount++)
    {
        string sCardName = llGetInventoryName(INVENTORY_NOTECARD, iCount);
        // Shorten card names to 8 chars for buttonlist
        sCardName = llGetSubString(sCardName, 0, 9);
        // Choose only data cards, not ManagerList
        if (sCardName != "ManagerList")
        {
            sNoteCardList += sCardName + "|";
        }
    }
    DebugTrace("sNoteCardList: " + sNoteCardList);
    list lstDataCards = llParseString2List(sNoteCardList, ["|"], []);
    iNItems = llGetListLength(lstDataCards);
    if (iNItems > 9)
    {
        llOwnerSay("Maximum: 9 data cards");
        return;
    }

    lstControlButtons += lstDataCards;

    // Display the dialog
    OpenMenu(keyDlg, sDialogMessage, lstControlButtons);
}
//==============================================================================
// Racer Menus
//==============================================================================
// MenuTeam: Prompt user for Team representing
//==============================================================================
MenuTeam(key keyDlg)
{
    // DebugTrace("MenuTeam()");

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
    string sBtn6 = "-";

    // DebugTrace("MenuAddDiv: sButtons=[" + sButtons + "]");

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

    lstControlButtons = [ "Start Over", "Cancel Reg", "-" ] +
                        [sBtn4] + [sBtn5] + "Done" +
                        [sBtn1] + [sBtn2] + [sBtn3];

    string sDialogMessage = "\nDivision: Please select the division to add:\n" +
                            "Div 1: 12 pts max. Div 2: 15 pts max.\n" +
                            "Div 3: 18 pts max. Open: 23 pts max.\n" +
                            "Bloodbath: Div 2 - Register to enter Bloodbath race.\n" +
                            "\"Done\" if you have no more entries.\n" +
                            "\"Start Over\" to change data.\n" +
                            "\"Cancel Reg\" to cancel your registration.\n";

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

    // DebugTrace("MenuAddName");

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
// MenuDeleted: Finalize new data
//==============================================================================
MenuDeleted(key keyDlg)
{
    string sDialogMessage = "\nYou are not registered for any races.\n\n" +
                            "You may register for races by clicking the banner.";

    DialogSay(keyDlg, sDialogMessage);
}
//==============================================================================
// MenuManagerTimeout: Manager Menu timed out
//==============================================================================
MenuManagerTimeout(key keyDlg)
{
    string sDialogMessage = "\nManager Menu timed out.";

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

    DebugTrace("sRacerButtonList: " + (string)iEndEntry + " entries");
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
    DebugTrace("sRacerList: " + sRacerList);
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

    string sDialogMessage = "Editing " + m_sPickRacer + "\n\n" +
                            "Select edit choice.\n\n" +
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
    /* DebugTrace("OpenMenu Key=" + (string)keyDlg +
               "\nChan=" + (string)m_iDialogChannel +
               "\nMsg=" + sDialogMessage +
               "\nButtons=" + (string)lstControlButtons); */
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
// Load Manager List
// Load list from note card "ManagerList"
//==============================================================================
LoadManagerList()
{
    // Set up dataserver to load note card
    m_sDataCard = "ManagerList";
    m_iNCLineNumber = 0;
    m_sManagerList = "";
    m_keyNumberOfLinesReq = llGetNumberOfNotecardLines(m_sDataCard);
}
//==============================================================================
// Load Race Data
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
    DebugTrace("Parse: " + sLine);

    if (m_sDataCard == "ManagerList")
    {
        m_sManagerList += "|" + sLine + "|";
    }
    else
    {
        if (iDataIndex < 0)
        {
            // Do nothing: An extraneous chat line was inserted
        }
        else if (llSubStringIndex(sLine, "BeginData") >= 0)
        {
            llRegionSayTo(m_keyDlg, 0, "loading data...");
            // Do nothing: Data begins on next line
        }
        else if (llSubStringIndex(sLine, "EndOfData") >= 0)
        {
            // Send all collected data
            TransferRaceData();
            llRegionSayTo(m_keyDlg, 0, "Load complete.");
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
SetRaceStatus()
{
    string sRegistration;
    string sLeagues;
    string sStatus;

    // Set Leagues caption
    sLeagues = "A, B, C, and D Leagues";
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

    // Set Registration status
    sRegistration = "closed";
    if (m_bRegistrationOpen)
    {
        sRegistration = "open";
    }

    // Set track status
    // DebugTrace("SetRaceStatus: m_sRiderDataList=[" + m_sRiderDataList + "]");
    integer iCount = iCountEntries();
    sStatus = "\n" + m_sTrackName;
    if (m_sRaceDayTime == "")
    {
        sStatus += ": No race is currently scheduled.\n";
    }
    else
    {
        sStatus += " on " + m_sRaceDayTime + "\n" +
                   "Racing " + sLeagues + "\n" +
                   "Registration is " + sRegistration + ". Entries so far: " +
                   (string)iCount + "\n";
    }

    m_sRaceStatus = sStatus;
    SendLnkCmd("d-m_sRaceStatus", m_sRaceStatus, iCount);
}
//==============================================================================
// CountEntries: Use a stack-based list to count the rider entries
//==============================================================================
integer iCountEntries()
{
    integer iNEntries;
    integer iEntry;
    string sEntry;
    integer iCount;

    // Get list of entries from m_sRiderDataList
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    iNEntries = llGetListLength(lstEntries);
    // DebugTrace("iCountEntries-A: iNEntries=" + (string)iNEntries);

    // Filter out incomplete entries
    iCount = 0;
    for (iEntry = 0; iEntry < iNEntries; iEntry++)
    {
        sEntry = llList2String(lstEntries, iEntry);
        // DebugTrace("sEntry(" + (string)iEntry + ")=[" + sEntry);
        if (llSubStringIndex(sEntry, ", , , , , ") < 0)
        {
            // Count only complete entries: at least 1 div registered
            iCount++;
        }
    }

    // DebugTrace("iCountEntries-B: iCount=" + (string)iCount);
    return iCount;
}
//==============================================================================
// TransferRaceData: Send race data to the Signup script
//==============================================================================
TransferRaceData()
{
    m_sRaceDayTime = m_sRaceDate + " at " + m_sRaceTime;
    llMessageLinked(LINK_THIS, 0, "m_sTrackName", m_sTrackName);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDate", m_sRaceDate);
    llMessageLinked(LINK_THIS, 0, "m_sRaceTime", m_sRaceTime);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDayTime", m_sRaceDayTime);
    llMessageLinked(LINK_THIS, m_iNLeagues, "m_iNLeagues", "");
    llMessageLinked(LINK_THIS, 0, "m_sRiderDataList", m_sRiderDataList);
    llMessageLinked(LINK_THIS, 0, "EndOfData", m_keyDlg);
}
//==============================================================================
// LnkMsgResponse: Process and act on received link messages
//==============================================================================
LnkMsgResponse(string sCmd, key keyData, integer iNum)
{
    // Set debug; placed before debug can echo
    if (sCmd == "m_bDebug")
    {
        m_bDebug = iNum;
        return;
    }

    string sData = (string)keyData;
    key keyDlg = keyData; // Key for dialog menus
    DebugTrace("LnkRsp: " + sCmd + "," + sData + "," + (string)iNum);
    // DebugTrace("LnkRsp: " + sCmd);

    if (llSubStringIndex(sCmd, "m_") == 0)
    {
        // Data Settings
        if (sCmd == "m_iDialogChannel")
        {
            m_iDialogChannel = iNum;
        }
        else if (sCmd == "m_sTrackName")
        {
            m_sTrackName = sData;
        }
        else if (sCmd == "m_sRaceDate")
        {
            m_sRaceDate = sData;
            // SetRaceStatus();
        }
        else if (sCmd == "m_sRaceTime")
        {
            m_sRaceTime = sData;
            // SetRaceStatus();
        }
        else if (sCmd == "m_sRaceDayTime")
        {
            m_sRaceDayTime = sData;
            SetRaceStatus();
        }
        else if (sCmd == "m_sNextRaceDayTime")
        {
            m_sNextRaceDayTime = sData;
        }
        else if (sCmd == "m_sNextRaceDate")
        {
            m_sNextRaceDate = sData;
        }
        else if (sCmd == "m_sNextRaceTime")
        {
            m_sNextRaceTime = sData;
        }
        else if (sCmd == "m_iNLeagues")
        {
            m_iNLeagues = iNum;
        }
        else if (sCmd == "m_keyDlg")
        {
            m_keyDlg = keyData;
        }
        else if (sCmd == "m_bRegistrationOpen")
        {
            m_bRegistrationOpen = iNum;
            SetRaceStatus();
        }
        else if (sCmd == "m_sRiderDataList")
        {
            m_sRiderDataList = sData;
        }
        else if (sCmd == "m_iRacerPage")
        {
            m_iRacerPage = iNum;
        }
        else if (sCmd == "m_sPickRacer")
        {
            m_sPickRacer = sData;
            MenuPickEdit(m_keyDlg);
            // Menu Calls
        }
    }
    else if (llSubStringIndex(sCmd, "Menu") == 0)
    {
        // All DisplayMenu calls come with integer m_bIsManager
        m_bIsManager = iNum;

        // Menu Settings
        if (sCmd == "MenuStartup")
        {
            MenuStartup(keyDlg, FALSE);
        }
        else if (sCmd == "MenuStartupReg")
        {
            MenuStartup(keyDlg, TRUE);
        }
        else if (sCmd == "MenuTeam")
        {
            MenuTeam(keyDlg);
        }
        else if (llSubStringIndex(sCmd, "MenuAddDiv") == 0)
        {
            string sButtons = llGetSubString(sCmd, 10, -1);
            // DebugTrace("sButtons=[" + sButtons + "]");
            MenuAddDiv(keyDlg, sButtons);
        }
        else if (sCmd == "MenuAddName")
        {
            MenuAddName(keyDlg);
        }
        else if (sCmd == "MenuManage")
        {
            MenuManage(keyDlg);
        }
        else if (sCmd == "MenuConfirmClear")
        {
            MenuConfirmClear(keyDlg);
        }
        else if (sCmd == "MenuConfirmNew")
        {
            MenuConfirmNew(keyDlg);
        }
        /* else if (sCmd == "MenuRaceDate")
        {
            MenuRaceDate(keyDlg);
        } */
        /* else if (sCmd == "MenuRaceTime")
        {
            MenuRaceTime(keyDlg);
        } */
        /* else if (sCmd == "MenuNumLgs")
        {
            MenuNumLgs(keyDlg);
        } */
        else if (sCmd == "MenuComplete")
        {
            MenuComplete(keyDlg);
        }
        else if (sCmd == "MenuDeleted")
        {
            MenuDeleted(keyDlg);
        }
        else if (sCmd == "MenuManagerTimeout")
        {
            MenuManagerTimeout(keyDlg);
        }
        else if (sCmd == "MenuPickRacer")
        {
            MenuPickRacer(keyDlg);
        }
        else if (sCmd == "MenuPickEdit")
        {
            MenuPickEdit(keyDlg);
        }
        else if (sCmd == "MenuPickData")
        {
            MenuPickData(keyDlg);
        }
    }
    else
    {
        // Operation Calls
        if (sCmd == "DisplayMemory")
        {
            DisplayMemory(keyDlg);
        }
        else if (sCmd == "SetRaceStatus")
        {
            m_sRiderDataList = sData;
            SetRaceStatus();
        }
        else if (sCmd == "SetRaceDayTime")
        {
            m_sRaceDayTime = m_sNextRaceDayTime;
            m_sRaceDate = m_sNextRaceDate;
            m_sRaceTime = m_sNextRaceTime;
            SetRaceStatus();
            SendLnkCmd("m_sRaceDate", m_sRaceDate, 0);
            SendLnkCmd("m_sRaceTime", m_sRaceTime, 0);
        }
        else if (sCmd == "Load Card")
        {
            m_sDataCard = sData;
            LoadRaceData();
        }
        else if (sCmd == "DialogSayClearing")
        {
            DialogSay(keyDlg, "Clearing race data and resetting script.");
        }
    }
}
//==============================================================================
// SendLnkCmd: Send a link message command
//==============================================================================
SendLnkCmd(string sCmd, string sData, integer iValue)
{
    // Truncate msg for DebugTrace
    string sMsg = llGetSubString(sData, 0, 400);
    DebugTrace("SndLnk " + sCmd + "," + sMsg + "," + (string)iValue);
    llMessageLinked(LINK_THIS, iValue, sCmd, sData);
}
// =========================================================================
// sSelectMsg: select only messages with no prefex or m_sMyPrefix (m-)
// =========================================================================
string sSelectMsg(string sMsg)
{
    // DebugTrace("sSelMsg: " + sMsg + "," + sMyPrefix);
    // Check the first 2 characters
    string sMsgPrefix = llGetSubString(sMsg, 0, 1);

    // Accept direct messages with my prefix
    if (sMsgPrefix == m_sMyPrefix)
    {
        string sMsg0 = sMsg;
        // Strip prefix
        sMsg = llGetSubString(sMsg, 2, -1);
    }
    // Ignore direct messages to others
    else if (llGetSubString(sMsg, 1, 1) == "-")
    {
        return "";
    }
    // Pass through all messages with my prefix or with no prefix
    return sMsg;
}
//==============================================================================
// DebugTrace(): llOwnerSay if in debug mode
// =============================================================================
DebugTrace(string sMsg)
{
    if (m_bDebug)
        llOwnerSay("[SignupMenu " + (string)llGetFreeMemory() + "] " + sMsg);
}
//==============================================================================
// DisplayMemory: Show version and free memory
//==============================================================================
DisplayMemory(key keyDlg)
{
    string sText = m_csVersion + " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
    {
        llRegionSayTo(keyDlg, 0, sText);
    }
    else
    {
        llSay(0, sText);
    }
}
//==============================================================================
// Event List
// =============================================================================
default
{
    // =========================================================================
    state_entry()
    {
        DisplayMemory("");

        LoadManagerList();
    }
    // =========================================================================
    on_rez(integer iNum)
    {
        llResetScript();
    }
    // =========================================================================
    link_message(integer iSender, integer iNum, string sCmd, key keyData)
    {
        // Deselect messages with prefix to other modules
        sCmd = sSelectMsg(sCmd);

        if (sCmd == "")
            return;

        // Process all messages to me and to all
        LnkMsgResponse(sCmd, keyData, iNum);
    }
    // =========================================================================
    dataserver(key keyRequested, string sData)
    {
        // DebugTrace("dataserver sData=" + sData);
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

        // Process card line
        m_sStatus = sData;
        if (m_sStatus == EOF)
        {
            if (m_sDataCard == "ManagerList")
            {
                SendLnkCmd("d-m_sManagerList", m_sManagerList, 0);
            }
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