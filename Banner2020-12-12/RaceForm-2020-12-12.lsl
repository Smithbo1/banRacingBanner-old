// =============================================================================
// TharlGate: TGRaceForm.lsl
// TGRaceForm: Display the Race Form and other printouts
// TharlGate, All rights reserved; Copyright 2016-2019; LauraTarnsman Resident
// Work in Progress:
// 1. Fix manage Edit Data button
// 3. Make Load Data button scan for available notecards
// 6. Create Show Data outside of manage menu
// ============================== Upd 2020-12-12 ============================
// Configuration
string m_csVersion = "2020-12-12";
integer m_bDebug = FALSE;
integer mc_iMaxHeat = 10;
string m_sTrackTag;
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";

// Comm
key m_keyDlg;

// Manage Race
string m_sTrackName;
string m_sRaceDate;
string m_sRaceTime;
integer m_iNEntries;
integer m_iNLeagues;

// Rider Database
string m_sRiderDataList;

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
//==============================================================================
// ReportMemory: Show version and free memory
//==============================================================================
ReportMemory(key keyDlg)
{
    string sText = "RaceForm: Ver. " + m_csVersion +
                   " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
        llRegionSayTo(keyDlg, 0, sText);
    else
        llSay(0, sText);
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
// =============================================================================
// PostRaceForm: Create a form containing races for each league
// =============================================================================
PostRaceForm()
{
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    m_iNEntries = llGetListLength(lstEntries);

    llRegionSayTo(m_keyDlg, 0, "\n" + sGetRaceName() + "\n");

    // PostRace(race_number, race_name, race_div, race_max_heat)
    integer iMaxHeat = mc_iMaxHeat;
    integer iRace = 0;
    PostRace(++iRace, "Bloodbath", 5, 10);
    PostRace(++iRace, "A League", 1, iMaxHeat);
    PostRace(++iRace, "A League", 2, iMaxHeat);
    PostRace(++iRace, "A League", 3, iMaxHeat);
    if (m_iNLeagues > 1)
    {
        PostRace(++iRace, "B League", 1, iMaxHeat);
        PostRace(++iRace, "B League", 2, iMaxHeat);
        PostRace(++iRace, "B League", 3, iMaxHeat);
    }
    if (m_iNLeagues > 2)
    {
        PostRace(++iRace, "C League", 1, iMaxHeat);
        PostRace(++iRace, "C League", 2, iMaxHeat);
        PostRace(++iRace, "C League", 3, iMaxHeat);
    }
    if (m_iNLeagues > 3)
    {
        PostRace(++iRace, "D League", 1, iMaxHeat);
        PostRace(++iRace, "D League", 2, iMaxHeat);
        PostRace(++iRace, "D League", 3, iMaxHeat);
    }
    PostRace(++iRace, "Combined", 4, iMaxHeat);

    if (m_keyDlg == m_sThaisKey || m_keyDlg == m_sKylieKey)
    {
        ReportMemory(m_keyDlg);
    }
    llResetScript();
}
// =============================================================================
// CombinedRaceForm: Create a form containing races for all leagues combined
// =============================================================================
CombinedRaceForm()
{
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    m_iNEntries = llGetListLength(lstEntries);

    llRegionSayTo(m_keyDlg, 0, "\n" + sGetRaceName() + "\n");

    // PostRace(race_number, race_name, race_div, race_max_heat)
    integer iMaxHeat = mc_iMaxHeat;
    PostRace(1, "Bloodbath", 5, 10);
    PostRace(2, "Combined", 1, iMaxHeat);
    PostRace(3, "Combined", 2, iMaxHeat);
    PostRace(4, "Combined", 3, iMaxHeat);
    PostRace(5, "Combined", 4, iMaxHeat);

    if (m_keyDlg == m_sThaisKey || m_keyDlg == m_sKylieKey)
    {
        ReportMemory(m_keyDlg);
    }
    llResetScript();
}
// =============================================================================
// PostRace(): Post a single race to private local chat
// =============================================================================
PostRace(integer iRaceNo, string sLeague, integer iDiv, integer iHeatMax)
{
    // Get and post entry for one race
    string sEntry = sGetRoster(iRaceNo, sLeague, iDiv, iHeatMax);
    llRegionSayTo(m_keyDlg, 0, sEntry);
}
// =============================================================================
// sGetRoster: Create roster for a single race
// =============================================================================
string sGetRoster(integer iRaceNo, string sLeague, integer iDiv, integer iHeatMax)
{
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    integer iNEntries = llGetListLength(lstEntries);

    string sRoster;
    string sRosterList;
    integer iNRacers;
    integer iRacer;
    string sRiderEntry;
    integer iElim1;
    integer iElim2;
    string sDiv;
    string sHeader;
    string sHeader2;
    string sHeader3;

    // Name the division racing
    sDiv = "DIV " + (string)iDiv + " ";
    if (iDiv == 4)
        sDiv = "OPEN";

    // Add racers to the roster who have registered
    for (iRacer = 0; iRacer < iNEntries; ++iRacer)
    {
        sRiderEntry = llList2String(lstEntries, iRacer);
        LoadRiderFields(sRiderEntry);

        integer iInclude = FALSE;
        if (m_sRiderLeague == sLeague)
            iInclude = TRUE;
        if (sLeague == "Combined" || sLeague == "Bloodbath")
            iInclude = TRUE;
        integer iRandom = (integer)llFrand(1000);

        if (iInclude &&
            ((iDiv == 1 && m_sRiderTharl1 != "") ||
             (iDiv == 2 && m_sRiderTharl2 != "") ||
             (iDiv == 3 && m_sRiderTharl3 != "") ||
             (iDiv == 4 && m_sRiderTharl4 != "") ||
             (iDiv == 5 && m_sRiderTharl5 != "")))
        {
            sRosterList += (string)iRacer + "," + (string)iRandom + "|";
        }
    }

    // Randomize list
    sRosterList = sSortKeyValList(sRosterList);
    list lstRoster = llParseString2List(sRosterList, ["|"], []);
    iNRacers = llGetListLength(lstRoster);

    // Create the Header
    integer iNBBaths = 1;
    if (iNRacers >= 16)
        iNBBaths = 2;

    sHeader = "RACE " + (string)iRaceNo + "\n";
    if (sLeague == "Bloodbath" && iNBBaths == 2)
    {
        sHeader += "*************** BLOODBATH 1 Div 2 **************";
        sHeader2 = "\n*************** BLOODBATH 2 Div 2 **************\n";
        sHeader3 = "\n=========== Bloodbath Alternates ================\n";
    }
    else if (sLeague == "Bloodbath")
    {
        sHeader += "*************** BLOODBATH Div 2 **************";
        sHeader2 = "\n=========== Bloodbath Alternates ================\n";
    }
    else
    {
        sHeader += "************ " + sLeague + " " + sDiv + " ***************";
    }
    sRoster = sHeader + "\n";

    // Set up bloodbath
    integer iBHeatMax = 10;
    if (iNRacers >= 16 && iNRacers < 20)
    {
        iBHeatMax = (integer)((iNRacers + 1) / 2);
    }

    // Go through the list of racers
    if (sLeague == "Bloodbath")
    {
        integer iEntry;
        integer iGate = 0;
        for (iEntry = 0; iEntry < iNRacers; ++iEntry)
        {
            if (iEntry == iBHeatMax)
            {
                // Split list in chat
                if (iNBBaths == 2)
                {
                    sRoster +=
                        "************** RACE RESULTS *******************\n\n";
                    sRoster +=
                        "***********************************************\n";
                }
                llRegionSayTo(m_keyDlg, 0, sRoster);
                sRoster = sHeader2;
                iGate = 0;
            }
            else if (iEntry == 20)
            {
                llRegionSayTo(m_keyDlg, 0, sRoster);
                sRoster = sHeader3;
                iGate = 0;
            }

            string sEntry = llList2String(lstRoster, iEntry);
            list lstEntry = llParseString2List(sEntry, [","], []);
            iRacer = llList2Integer(lstEntry, 0);

            sRiderEntry = llList2String(lstEntries, iRacer);
            LoadRiderFields(sRiderEntry);

            string sLine = (string)(++iGate) + ". " + m_sRiderName;
            string sTharlName = m_sRiderTharl1;
            if (iDiv == 2)
            {
                sTharlName = m_sRiderTharl2;
            }
            else if (iDiv == 3)
            {
                sTharlName = m_sRiderTharl3;
            }
            else if (iDiv == 4)
            {
                sTharlName = m_sRiderTharl4;
            }
            else if (iDiv == 5)
            {
                sTharlName = m_sRiderTharl5;
            }
            sLine += " on " + sTharlName;
            if (m_sRiderTeam != "")
                sLine += " riding for " + m_sRiderTeam;
            sRoster += sLine + "\n";
        }
        sRoster += "************** RACE RESULTS *******************\n\n";
        sRoster += "***********************************************\n";

        return sRoster;
    }

    // If iNRacers > iHeatMax, then Elimination Heats
    iElim1 = -1;
    iElim2 = -1;

    if (iNRacers > iHeatMax)
    { // Over iHeatMax: 2 elimination heats
        iElim1 = (iNRacers + 1) / 2;
        if (iNRacers > 2 * iHeatMax)
        { // Over 2 x iHeatMax: 3 elimination heats
            iElim1 = (iNRacers + 2) / 3;
            iElim2 = iElim1 + (iNRacers + 1) / 3;
        }
        sRoster +=
            "=========== Elimination Heat 1 ================\n";
    }

    integer iEntry;
    integer iGate = 0;
    for (iEntry = 0; iEntry < iNRacers; ++iEntry)
    {
        if (iEntry == iElim1)
        {
            // Split heats in chat if more than 1
            llRegionSayTo(m_keyDlg, 0, sRoster);
            sRoster =
                "\n=========== Elimination Heat 2 ================\n";
            iGate = 0;
        }
        if (iEntry == iElim2)
        {
            // Split heats in chat if more than 1
            llRegionSayTo(m_keyDlg, 0, sRoster);
            sRoster =
                "\n=========== Elimination Heat 3 ================\n";
            iGate = 0;
        }
        string sEntry = llList2String(lstRoster, iEntry);
        list lstEntry = llParseString2List(sEntry, [","], []);
        iRacer = llList2Integer(lstEntry, 0);

        sRiderEntry = llList2String(lstEntries, iRacer);
        LoadRiderFields(sRiderEntry);

        string sLine = (string)(++iGate) + ". " + m_sRiderName;
        string sTharlName = m_sRiderTharl1;
        if (iDiv == 2)
        {
            sTharlName = m_sRiderTharl2;
        }
        else if (iDiv == 3)
        {
            sTharlName = m_sRiderTharl3;
        }
        else if (iDiv == 4)
        {
            sTharlName = m_sRiderTharl4;
        }
        sLine += " on " + sTharlName;
        if (m_sRiderTeam != "")
            sLine += " riding for " + m_sRiderTeam;
        sRoster += sLine + "\n";
    }

    if (iElim1 > 0)
        sRoster +=
            "========================================\n";

    sRoster += "************** RACE RESULTS *******************\n\n";
    sRoster += "***********************************************\n";

    return sRoster;
}
// =============================================================================
// Sort a list of form: "sKey,fVal|sKey,fVal| ... sKey,fVal|" lowest to highest
// =============================================================================
string sSortKeyValList(string sKeyValList)
{
    string sNewList = "";
    list lstKeyVal = llParseString2List(sKeyValList, ["|"], []);
    integer iListLength = llGetListLength(lstKeyVal);
    while (iListLength > 0)
    {
        integer iMinValue = 100000000;
        string sMinEntry;
        integer iMinEntry;
        integer iEntry;
        for (iEntry = 0; iEntry < iListLength; ++iEntry)
        {
            string sEntry = llList2String(lstKeyVal, iEntry);

            list lstEntry = llParseString2List(sEntry, [","], []);
            integer iValue = llList2Integer(lstEntry, 1);
            if (iValue < iMinValue)
            {
                iMinValue = iValue;
                sMinEntry = sEntry;
                iMinEntry = iEntry;
            }
        }
        sNewList += sMinEntry + "|";
        lstKeyVal = llDeleteSubList(lstKeyVal, iMinEntry, iMinEntry);
        --iListLength;
    }
    return sNewList;
}
//==============================================================================
// ShowData: Display entered race data in chat window
//==============================================================================
ShowData()
{
    // Extract racer entries and get number of entries
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    m_iNEntries = llGetListLength(lstEntries);
    // Display race header
    llRegionSayTo(m_keyDlg, 0, "\n" + sGetRaceName());

    // If no entries, just quit
    if (!m_iNEntries)
        return;

    // Create a simplified rider list with league, racer name, races entered
    integer iCount;

    // For each racer, send a data line
    string sAList;
    string sBList;
    string sCList;
    string sDList;
    integer iACount;
    integer iBCount;
    integer iCCount;
    integer iDCount;

    for (iCount = 0; iCount < m_iNEntries; ++iCount)
    {
        string sRiderEntry = llList2String(lstEntries, iCount);
        LoadRiderFields(sRiderEntry);

        string sEntry = m_sRiderLeague + ": " + m_sRiderName + " in ";
        if (m_sRiderTharl5 != "")
            sEntry += "Bloodbath ";
        if (m_sRiderTharl1 != "")
            sEntry += "D1 ";
        if (m_sRiderTharl2 != "")
            sEntry += "D2 ";
        if (m_sRiderTharl3 != "")
            sEntry += "D3 ";
        if (m_sRiderTharl4 != "")
            sEntry += "Open ";

        string sLeague = llGetSubString(sEntry, 0, 0);

        if (sLeague == "A")
        {
            sAList = sAList + "\n" + (string)(++iACount) + ". " + sEntry;
        }
        else if (sLeague == "B")
        {
            sBList = sBList + "\n" + (string)(++iBCount) + ". " + sEntry;
        }
        else if (sLeague == "C")
        {
            sCList = sCList + "\n" + (string)(++iCCount) + ". " + sEntry;
        }
        else if (sLeague == "D")
        {
            sDList = sDList + "\n" + (string)(++iDCount) + ". " + sEntry;
        }
    }

    if (sAList != "")
        llRegionSayTo(m_keyDlg, 0, sAList);
    if (sBList != "")
        llRegionSayTo(m_keyDlg, 0, sBList);
    if (sCList != "")
        llRegionSayTo(m_keyDlg, 0, sCList);
    if (sDList != "")
        llRegionSayTo(m_keyDlg, 0, sDList);

    if (m_keyDlg == m_sThaisKey || m_keyDlg == m_sKylieKey)
    {
        ReportMemory(m_keyDlg);
    }
    llResetScript();
}
//==============================================================================
// LoadRiderFields: Load data from current avatar into single fields
//==============================================================================
LoadRiderFields(string sRiderEntry)
{
    // Parse the entry and load the module fields
    list lstRiderData = llParseString2List(sRiderEntry, [","], ["|"]);

    // Get fields from data; Open new listener each load
    m_sKeyRider = llList2String(lstRiderData, 0);
    m_sRiderStep = llList2String(lstRiderData, 1);
    m_sRiderLegacyName = llList2String(lstRiderData, 2);
    m_sRiderDisplayName = sGetField(lstRiderData, 3);
    m_sRiderLeague = sGetField(lstRiderData, 4);
    m_sRiderTeam = sGetField(lstRiderData, 5);
    m_sRiderTharl1 = sGetField(lstRiderData, 6);
    m_sRiderTharl2 = sGetField(lstRiderData, 7);
    m_sRiderTharl3 = sGetField(lstRiderData, 8);
    m_sRiderTharl4 = sGetField(lstRiderData, 9);
    m_sRiderTharl5 = sGetField(lstRiderData, 10);

    m_sRiderName = m_sRiderDisplayName;
    if (m_sRiderName == "")
    {
        m_sRiderName = m_sRiderLegacyName;
    }
    else if (m_sRiderName != m_sRiderLegacyName)
    {
        m_sRiderName += " (" + m_sRiderLegacyName + ")";
    }
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
// =============================================================================
// =============================================================================
//==============================================================================
// DebugSay(): llOwnerSay if in debug mode
// =============================================================================
DebugSay(string sMsg)
{
    if (m_bDebug)
        llOwnerSay("[RaceForm] " + sMsg);
}
// =============================================================================
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

        // Operation Calls
        if (sCommand == "ReportMemory")
        {
            ReportMemory(keyDlg);
        }
        else if (sCommand == "Show Data")
        {
            m_sRiderDataList = sText;
            ShowData();
        }
        else if (sCommand == "Race Form")
        {
            m_sRiderDataList = sText;
            PostRaceForm();
        }
        else if (sCommand == "Combined")
        {
            m_sRiderDataList = sText;
            CombinedRaceForm();
        }
        else if (sCommand == "SendIM")
        {
            llInstantMessage(m_sSandiKey, sText);
            // Data Settings
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
    }
    // =========================================================================
}
// =============================================================================
