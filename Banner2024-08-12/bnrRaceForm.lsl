// =============================================================================
// TharlGate: bnrRaceForm.lsl
// bnrRaceForm: Display the Race Form and other printouts
// TharlGate, All rights reserved; Copyright 2016-2024; LauraTarnsman Resident
// ============================== Upd 2024-08-12 ============================
// Configuration
string m_csVersion = "bnrRaceForm (2024-08-12)";
integer m_bDebug = FALSE;
integer mc_iMaxHeat = 10;
string m_sTrackTag;
string m_sThaisKey = "680601ff-b624-4eab-941b-5382f4e2f0d4";
string m_sKylieKey = "3f6b1612-6cc3-4548-85e4-3aef3969d2e9";
string m_sSandiKey = "4bf82070-2692-4e86-8936-674a1b103954";
string m_sMyPrefix = "f-";

// Manage Race
string m_sTrackName;
string m_sRaceDate;
string m_sRaceTime;
string m_sNextRaceDayTime;
string m_sRaceStatus;
integer m_iNLeagues;
integer m_iNEntries;
integer m_iRaceNo;

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
// =============================================================================
// PostRaceForm: Create a form containing races for each league
// =============================================================================
PostRaceForm(key keyDlg)
{
    CountEntries();

    llRegionSayTo(keyDlg, 0, "\n" + m_sRaceStatus + "\n");

    // PostRace(race_number, race_name, race_div, race_max_heat)
    integer iMaxHeat = mc_iMaxHeat;
    m_iRaceNo = 0;
    PostRace(keyDlg, "Bloodbath", 5, 10);

    PostRace(keyDlg, "A League", 1, iMaxHeat);
    PostRace(keyDlg, "A League", 2, iMaxHeat);
    PostRace(keyDlg, "A League", 3, iMaxHeat);
    if (m_iNLeagues > 1)
    {
        PostRace(keyDlg, "B League", 1, iMaxHeat);
        PostRace(keyDlg, "B League", 2, iMaxHeat);
        PostRace(keyDlg, "B League", 3, iMaxHeat);
    }
    if (m_iNLeagues > 2)
    {
        PostRace(keyDlg, "C League", 1, iMaxHeat);
        PostRace(keyDlg, "C League", 2, iMaxHeat);
        PostRace(keyDlg, "C League", 3, iMaxHeat);
    }
    if (m_iNLeagues > 3)
    {
        PostRace(keyDlg, "D League", 1, iMaxHeat);
        PostRace(keyDlg, "D League", 2, iMaxHeat);
        PostRace(keyDlg, "D League", 3, iMaxHeat);
    }
    PostRace(keyDlg, "Combined", 4, iMaxHeat);

    if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
    {
        DisplayMemory(keyDlg);
    }
    llResetScript();
}
// =============================================================================
// PostRace(): Post a single race to private local chat
// =============================================================================
PostRace(key keyDlg, string sLeague, integer iDiv, integer iHeatMax)
{
    // Get and post entry for one race
    m_iRaceNo++;
    string sEntry = sGetRoster(keyDlg, sLeague, iDiv, iHeatMax);
}
// =============================================================================
// sGetRoster: Create roster for a single race
// =============================================================================
string sGetRoster(key keyDlg, string sLeague, integer iDiv, integer iHeatMax)
{
    /* CountEntries(); */

    string sRoster;
    string sRosterList;
    integer iNRacers;
    integer iRacer;
    string sRiderEntry;
    integer iElim1;
    integer iElim2;
    integer iElim3;
    string sDiv;
    string sHeader;
    string sResults =
        "************** RACE RESULTS *******************\n\n" +
        "***********************************************\n";
    string sHeatResults =
        "************** HEAT RESULTS *******************\n\n" +
        "***********************************************\n";
    string sOpenResults =
        "************** OPEN RESULTS *******************\n\n" +
        "***********************************************\n";

    // Name the division racing
    sDiv = "DIV " + (string)iDiv + " ";
    if (iDiv == 4)
    {
        sDiv = "OPEN";
    }

    for (iRacer = 0; iRacer < m_iNEntries; ++iRacer)
    {
        // Create list of entries with rider data
        list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
        sRiderEntry = llList2String(lstEntries, iRacer);

        LoadRiderFields(sRiderEntry); // Set globals for rider data

        integer iInclude = FALSE;
        if (m_sRiderLeague == sLeague)
            iInclude = TRUE;
        if (sLeague == "Combined" || sLeague == "Bloodbath")
            iInclude = TRUE;

        if (iInclude &&
            ((iDiv == 1 && m_sRiderTharl1 != "") ||
             (iDiv == 2 && m_sRiderTharl2 != "") ||
             (iDiv == 3 && m_sRiderTharl3 != "") ||
             (iDiv == 4 && m_sRiderTharl4 != "") ||
             (iDiv == 5 && m_sRiderTharl5 != "")))
        {
            sRosterList += (string)iRacer + "|";
        }
    }

    // Randomize list
    list lstRoster1 = llParseString2List(sRosterList, ["|"], []);
    list lstRoster = llListRandomize(lstRoster1, 1);
    iNRacers = llGetListLength(lstRoster);
    string sEntry;

    // Create the Header
    integer iElim;
    integer iMax1;
    integer iMax2;
    integer iMax3;

    // Set max number per heat
    // Initialize to avoid mischief
    iMax1 = iMax2 = iMax3 = 99;

    // Check each tier
    if (iNRacers <= 10)
    {
        iMax1 = 10;
    }
    else if (iNRacers <= 20)
    {
        iMax1 = (integer)(iNRacers + 1) / 2;
    }
    else if (iNRacers <= 30)
    {
        iMax1 = (integer)(iNRacers + 2) / 3;
        iMax2 = iMax1 + (integer)(iNRacers - iMax1 + 1) / 2;
    }
    else if (iNRacers <= 40)
    {
        iMax1 = (integer)(iNRacers + 3) / 4;
        iMax2 = iMax1 + (integer)(iNRacers - iMax1 + 2) / 3;
        iMax3 = iMax2 + (integer)(iNRacers - iMax2 + 1) / 2;
    }

    // Set up bloodbath
    // ToDo: Set up a test loop for 1 to 42 racers
    DebugTrace("sGetRoster--" + sLeague + ": " + (string)iNRacers + " racers.");
    integer iClip = FALSE;
    iElim = 1;
    if (sLeague == "Bloodbath")
    {
        integer iEntry;
        integer iGate = 0;
        integer iMinB = 8;
        integer iNBBaths = 1;
        integer iBBath = 1;
        integer iNRacers1 = iNRacers;
        integer iNRacers2 = 0;
        integer iNRacers3 = 0;
        integer iNAlts = 0;

        DebugTrace("iNRacers/iMinB = " + (string)iNRacers + "/" + (string)iMinB);
        if (iNRacers < 2 * iMinB) // 1 Bloodbath
        {
            iNRacers1 = iNRacers;
            iNRacers2 = iNRacers3 = iNAlts = 0;
            if (iNRacers1 > 10)
            {
                iNRacers1 = 10;
            }
            iNAlts = iNRacers - iNRacers1;
            DebugTrace("Setup 1 BB: " + (string)iNRacers1 + "/" + (string)iNRacers2 + "/" +
                       (string)iNRacers3 + "/" + (string)iNAlts);
        }
        else if (iNRacers < 3 * iMinB) // 2 Bloodbaths
        {
            DebugTrace("Setup 2 BB");
            iNBBaths = 2;
            iNRacers2 = iNRacers / 2;
            iNRacers1 = iNRacers - iNRacers2;
            if (iNRacers1 > 10)
            {
                iNRacers1 = 10;
            }
            if (iNRacers2 > 10)
            {
                iNRacers2 = 10;
            }
            iNAlts = iNRacers - iNRacers1 - iNRacers2;
        }
        else if (iNRacers < 4 * iMinB) // 3 Bloodbaths
        {
            DebugTrace("Setup 3 BB");
            iNBBaths = 3;
            iNRacers3 = iNRacers / 3;
            DebugTrace("iNRacers3 = " + (string)iNRacers3);
            iNRacers2 = (iNRacers - iNRacers3) / 2;
            DebugTrace("iNRacers2 = " + (string)iNRacers2);
            iNRacers1 = iNRacers - iNRacers2 - iNRacers3;
            DebugTrace("iNRacers1 = " + (string)iNRacers1);
            if (iNRacers1 > 10)
            {
                iNRacers1 = 10;
            }
            if (iNRacers2 > 10)
            {
                iNRacers2 = 10;
            }
            if (iNRacers3 > 10)
            {
                iNRacers3 = 10;
            }
            DebugTrace("iNRacers = " + (string)iNRacers);
            iNAlts = iNRacers - iNRacers1 - iNRacers2 - iNRacers3;
            DebugTrace("iNAlts = " + (string)iNAlts);
        }

        DebugTrace("sGetRoster: " + (string)iNBBaths + " 1/2/3/A " +
                   (string)iNRacers1 + "/" + (string)iNRacers2 + "/" +
                   (string)iNRacers3 + "/" + (string)iNAlts);

        sHeader = sGetBBHeader(iElim);
        sRoster = sHeader + "\n";

        for (iEntry = 0; iEntry < iNRacers; ++iEntry)
        {
            integer iRacer = iEntry + 1; // Get actual racer number

            if (iRacer == iNRacers1 + 1) // Last racer in race 1
            {
                DebugTrace("BB First racer for BB2");
                if (iNBBaths == 1)
                {
                    sRoster += sGetBBHeader(0) + "\n"; // Set alts header
                }
                else
                {
                    // Send out first race
                    sRoster += sResults;
                    llRegionSayTo(keyDlg, 0, sRoster);
                    // Set up race 2
                    m_iRaceNo++;
                    iElim++;
                    sRoster = sGetBBHeader(iElim) + "\n";
                }
                iGate = 0;
            }
            else if (iRacer == iNRacers2 + iNRacers1 + 1) // Last racer in race 2
            {
                DebugTrace("BB First racer for BB3");
                if (iNBBaths == 2)
                {
                    sRoster += sGetBBHeader(0) + "\n"; // Set alts header
                }
                else
                {
                    // Send out second race
                    sRoster += sResults;
                    llRegionSayTo(keyDlg, 0, sRoster);
                    // Set up race 3
                    m_iRaceNo++;
                    iElim++;
                    sRoster = sGetBBHeader(iElim) + "\n";
                }
                iGate = 0;
            }
            else if (iRacer == iNRacers3 + iNRacers2 + iNRacers1 + 1) // Last racer in race 3
            {
                DebugTrace("BB First racer for BB4");
                if (iNBBaths == 3)
                {
                    sRoster += sGetBBHeader(0) + "\n"; // Set alts header
                }
                else
                {
                    // Send out third race
                    sRoster += sResults;
                    llRegionSayTo(keyDlg, 0, sRoster);
                    // Set up race 4
                    m_iRaceNo++;
                    iElim++;
                    sRoster = sGetBBHeader(iElim) + "\n";
                }
                iGate = 0;
            }
            else if (iRacer == iNRacers3 + iNRacers2 + iNRacers1 + 1 &&
                     iNAlts > 0)
            {
                // Only alts left
                sRoster += sGetBBHeader(0) + "\n";
                iGate = 0;
            }

            sEntry = llList2String(lstRoster, iEntry);
            list lstEntry = llParseString2List(sEntry, [","], []);
            iRacer = llList2Integer(lstEntry, 0);

            list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
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
        // After last racer
        sRoster += sResults;
        llRegionSayTo(keyDlg, 0, sRoster);

        return sRoster;
    }
    else
    {

        iElim = 1;
        sHeader = sGetRaceHeader(1, sDiv, sLeague);
        sRoster = sHeader + "\n";
        if (iNRacers > 10)
        {
            sRoster += sGetElimHeader(iElim) + "\n";
        }

        integer iEntry;
        integer iGate = 0;

        for (iEntry = 0; iEntry < iNRacers; ++iEntry)
        {

            if (iEntry == iMax1) // We are 1 over max1
            {
                // Split list in chat
                sRoster += sHeatResults;
                llRegionSayTo(keyDlg, 0, sRoster);
                //===============
                m_iRaceNo++;
                iElim++;
                sRoster = sGetElimHeader(iElim) + "\n";
                iGate = 0;
            }
            else if (iEntry == iMax2)
            {
                // Split list in chat
                sRoster += sHeatResults;
                llRegionSayTo(keyDlg, 0, sRoster);
                //===============
                m_iRaceNo++;
                iElim++;
                sRoster = sGetElimHeader(iElim) + "\n";
                iGate = 0;
            }
            else if (iEntry == iMax3)
            {
                // Split list in chat
                sRoster += sHeatResults;
                llRegionSayTo(keyDlg, 0, sRoster);
                //===============
                m_iRaceNo++;
                iElim++;
                sRoster = sGetElimHeader(iElim) + "\n";
                iGate = 0;
            }

            sEntry = llList2String(lstRoster, iEntry);
            list lstEntry = llParseString2List(sEntry, [","], []);
            iRacer = llList2Integer(lstEntry, 0);

            list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
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

        if (iNRacers > 10)
        {
            sRoster += sHeatResults + "\n";
            if (iDiv == 4)
            {
                sRoster += sOpenResults;
            }
            else
            {
                sRoster += sResults;
            }
        }
        else
        {
            sRoster += sResults;
        }
        llRegionSayTo(keyDlg, 0, sRoster);

        return sRoster;
    }
}
// =============================================================================
// Get bloodbath header
// =============================================================================
string sGetBBHeader(integer iBBath)
{
    string sHeader;
    if (iBBath == 0)
    {
        sHeader = "=========== Bloodbath Alternates ================";
    }
    else
    {
        sHeader = "RACE " + (string)m_iRaceNo + "\n" +
                  "*************** BLOODBATH " + (string)iBBath +
                  " Div 2 **************";
    }
    return sHeader;
}
// =============================================================================
// Get elimination header
// =============================================================================
string sGetElimHeader(integer iElim)
{
    string sHeader;
    if (iElim > 1)
    {
        sHeader = "RACE " + (string)m_iRaceNo + "\n";
    }
    sHeader += "========== Elimination Heat " + (string)iElim + " ==========";
    return sHeader;
}
// =============================================================================
// Get race header
// =============================================================================
string sGetRaceHeader(integer iElim, string sDiv, string sLeague)
{
    string sHeader = "RACE " + (string)m_iRaceNo + "\n" +
                     "************ " + sLeague + " " + sDiv + " ***************";
    return sHeader;
}
//==============================================================================
// ShowData: Display entered race data in chat window
//==============================================================================
ShowData(key keyDlg)
{
    DebugTrace("ShowData keyDlg = " + (string)keyDlg);

    // Extract racer entries and get number of entries
    CountEntries();
    // Count rider entries and store in m_iNEntries

    // Display race header
    llRegionSayTo(keyDlg, 0, "\n" + m_sRaceStatus);

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
    string sEntry;
    string sLeague;
    integer iACount;
    integer iBCount;
    integer iCCount;
    integer iDCount;

    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);

    for (iCount = 0; iCount < m_iNEntries; ++iCount)
    {
        string sRiderEntry = llList2String(lstEntries, iCount);
        LoadRiderFields(sRiderEntry);

        sEntry = m_sRiderLeague + ": " + m_sRiderName + " in ";
        integer iNRaces = 0;
        if (m_sRiderTharl5 != "")
        {
            sEntry += "Bloodbath ";
            iNRaces++;
        }
        if (m_sRiderTharl1 != "")
        {
            sEntry += "D1 ";
            iNRaces++;
        }
        if (m_sRiderTharl2 != "")
        {
            sEntry += "D2 ";
            iNRaces++;
        }
        if (m_sRiderTharl3 != "")
        {
            sEntry += "D3 ";
            iNRaces++;
        }
        if (m_sRiderTharl4 != "")
        {
            sEntry += "Open ";
            iNRaces++;
        }
        if (!iNRaces)
        {
            sEntry += " !! No Races Entered !!";
        }

        sLeague = llGetSubString(sEntry, 0, 0);

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
        llRegionSayTo(keyDlg, 0, sAList);
    if (sBList != "")
        llRegionSayTo(keyDlg, 0, sBList);
    if (sCList != "")
        llRegionSayTo(keyDlg, 0, sCList);
    if (sDList != "")
        llRegionSayTo(keyDlg, 0, sDList);

    if (keyDlg == m_sThaisKey || keyDlg == m_sKylieKey)
    {
        DisplayMemory(keyDlg);
    }
    // llResetScript();
}
//==============================================================================
// CountEntries: Use a stack-based list to count the rider entries
//==============================================================================
CountEntries()
{
    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    m_iNEntries = llGetListLength(lstEntries);
    DebugTrace("CountEntries: m_iNEntries=" + (string)m_iNEntries);
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
    DebugTrace("LnkRsp: " + sCmd);
    // DebugTrace("LnkRsp: " + sCmd + "," + sData + "," + (string)iNum);

    if (llSubStringIndex(sCmd, "m_") == 0)
    {
        // Data Settings
        if (sCmd == "m_sRiderDataList")
        {
            m_sRiderDataList = sData;
        }
        else if (sCmd == "m_sTrackName")
        {
            m_sTrackName = sData;
        }
        else if (sCmd == "m_sNextRaceDayTime")
        {
            m_sNextRaceDayTime = sData;
        }
        else if (sCmd == "m_sRaceDate")
        {
            m_sRaceDate = sData;
        }
        else if (sCmd == "m_sRaceTime")
        {
            m_sRaceTime = sData;
        }
        else if (sCmd == "m_sRaceStatus")
        {
            m_sRaceStatus = sData;
            m_iNEntries = iNum;
        }
        else if (sCmd == "m_iNLeagues")
        {
            m_iNLeagues = iNum;
        }
    }
    else
    {
        // Operation Calls
        if (sCmd == "DisplayMemory")
        {
            DisplayMemory(keyData);
        }
        else if (sCmd == "Show Data")
        {
            DebugTrace("lnkRsp-Show Data");
            key keyDlg = sData;
            ShowData(keyDlg);
        }
        else if (sCmd == "Race Form")
        {
            key keyDlg = sData;
            PostRaceForm(keyDlg);
        }
        else if (sCmd == "SendIM")
        {
            llInstantMessage(m_sSandiKey, sData);
        }
    }
}
// =========================================================================
// sSelectMsg: select only messages with no prefex or m_sMyPrefix (f-)
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
        llOwnerSay("[RaceForm " + (string)llGetFreeMemory() + "] " + sMsg);
}
//==============================================================================
// DisplayMemory: Show version and free memory
//==============================================================================
DisplayMemory(key keyDlg)
{
    string sText = m_csVersion + " Free Memory: " + (string)llGetFreeMemory();
    if (keyDlg != "")
        llRegionSayTo(keyDlg, 0, sText);
    else
        llSay(0, sText);
}
// =============================================================================
// Event List
// =============================================================================
default
{
    // =========================================================================
    state_entry()
    {
        DisplayMemory("");
    }
    // =========================================================================
    on_rez(integer iNum)
    {
        llResetScript();
    }
    //======================================
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
}
// =============================================================================
 