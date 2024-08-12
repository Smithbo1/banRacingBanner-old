// =============================================================================
// TharlGate: bnrSignupHelper.lsl
// bnrSignupHelper:
// TharlGate, All rights reserved; Copyright 2016-2024; LauraTarnsman Resident
// ============================== Upd 2024-08-12 ============================
// Configuration
string m_csVersion = "bnrSignupHelper (2024-08-12)";
integer m_bDebug = FALSE;
string m_sMyPrefix = "h-";

// Note Card
key m_keyNumberOfLinesReq; // Notecard request key
key m_keyLineReadRequest;  // Notecard line request key
integer m_iTotalNCLines;   // Number of notecard lines
integer m_iNCLineNumber;   // Current notecard line number
string m_sStatus;          // Notecard read status (EOF)
string m_sManagerCard;     // Notecard name for manager list

// Race Data
integer m_iNLeagues;
string m_sTrackName;
string m_sRiderDataList;
string m_sRecoveryData; // Save Data results for a notecard
integer m_iRecoveryLoc; // Current recovery location in m_sRecoveryData

// Current Rider Fields
string m_sKeyRider;
string m_sRiderLegacyName;
string m_sRiderDisplayName;
string m_sRiderLeague;
string m_sRiderTeam;
string m_sTharl1;
string m_sTharl2;
string m_sTharl3;
string m_sTharl4;
string m_sTharl5;
string m_keyDlg;
string m_sRiderStep;

// Date Values
string m_sRaceDate;
string m_sRaceTime;
string m_sNextRaceDate;
string m_sNextRaceTime;
string m_sNextRaceDayTime;
string m_sRaceDayTime;
integer m_iOpenRegCode; // date code for opening registration
//==============================================================================
SetNextRaceDay()
{
    string sRaceDow;
    string sRaceTime;
    string sRaceDate;
    string sRaceDayTime;
    integer iAddDays;
    integer iDateCode;
    integer iRaceDayCode;
    integer iOpenRegCode;

    // Get today's date
    integer iYear;
    integer iMonth;
    integer iDay;
    integer iTodayDow;
    integer iRaceDow;

    string sToday = llGetDate();
    iYear = (integer)llGetSubString(sToday, 0, 3);
    iMonth = (integer)llGetSubString(sToday, 5, 6);
    iDay = (integer)llGetSubString(sToday, 8, 9);

    iTodayDow = iDayOfWeek(iYear, iMonth, iDay);

    // Find next race day
    if (iTodayDow <= 4)
    {
        // Before Weds
        iRaceDow = 4; // Raceday is 1 PM Weds
        sRaceTime = "1 pm slt";
        sRaceDow = "Wednesday";
    }
    else
    {
        // After Weds
        iRaceDow = 7; // Race is 9 AM Saturday
        sRaceTime = "9 am slt";
        sRaceDow = "Saturday";
    }

    iAddDays = iRaceDow - iTodayDow;

    // Get today's date code
    list lstDateTime = [ iYear, iMonth, iDay, 1, 1, 1 ];
    iDateCode = uStamp2UnixInt(lstDateTime);
    iRaceDayCode = iAddDays(iDateCode, iAddDays); // Date of next race
    iOpenRegCode = iAddDays(iRaceDayCode, -1);    // Date to open registration

    sRaceDate = sDateFromCode(iRaceDayCode);
    sRaceDate = sRaceDow + ", " + sRaceDate;
    m_sNextRaceDayTime = sRaceDate + " at " + sRaceTime;
    m_sNextRaceDate = sRaceDate;
    m_sNextRaceTime = sRaceTime;

    SendLnkCmd("m-m_sNextRaceDayTime", m_sNextRaceDayTime, 0);
    SendLnkCmd("m-m_sNextRaceDate", m_sNextRaceDate, 0);
    SendLnkCmd("m-m_sNextRaceTime", m_sNextRaceTime, 0);
}
//==============================================================================
//                       Anti-License Text
//     Contributed Freely to the Public Domain without limitation.
//   2009 (CC0) [ http://creativecommons.org/publicdomain/zero/1.0 ]
//  Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]
//==============================================================================
integer iDayOfWeek(integer iYear, integer iMonth, integer iDay)
{
    // Formula for day of week given iYear, iMonth, iDay
    // See Wiki llGetTimeStamp() helper fcn uStamp2WeekdayStr()
    integer iDow;
    iDow = (iYear + (iYear >> 2) - ((iMonth < 3) & !(iYear & 3)) + iDay +
            (integer)llGetSubString("_033614625035", iMonth, iMonth)) %
           7;
    // Convert from [Fri to Thur] to [Sun to Mon] = [1 to 7]
    iDow -= 1;
    if (iDow < 1)
    {
        iDow += 7; // Current iDow is Sun-Sat, 1-7
    }
    return iDow;
}
//==============================================================================
// Returns an integer that is the Unix time code represented by the input list
// vLstStp: source time stamp list of format [Y, M, D, h, m, s]
//==============================================================================
integer uStamp2UnixInt(list vLstStp)
{
    integer vIntYear = llList2Integer(vLstStp, 0) - 1902;
    integer vIntRtn;
    if (vIntYear >> 31 | vIntYear / 136)
    {
        vIntRtn = 2145916800 * (1 | vIntYear >> 31);
    }
    else
    {
        integer vIntMnth = ~-llList2Integer(vLstStp, 1);
        integer vIntDays = ~-llList2Integer(vLstStp, 2);
        vIntMnth = llAbs((vIntMnth + !~vIntMnth) % 12);
        vIntRtn = 86400 * ((integer)(vIntYear * 365.25 + 0.25) - 24837 +
                           vIntMnth * 30 + (vIntMnth - (vIntMnth < 7) >> 1) +
                           (vIntMnth < 2) -
                           (((vIntYear + 2) & 3) > 0) * (vIntMnth > 1) +
                           llAbs((vIntDays + !~vIntDays) % 31)) +
                  llAbs(llList2Integer(vLstStp, 3) % 24) * 3600 +
                  llAbs(llList2Integer(vLstStp, 4) % 60) * 60 +
                  llAbs(llList2Integer(vLstStp, 5) % 60);
    }
    return vIntRtn;
}
//==============================================================================
// Returns list: Unix time code converted to the format [Y, M, D, h, m, s]
// vIntDat: source Unix time code to convert
//==============================================================================
list uUnix2StampLst(integer vIntDat)
{
    if (vIntDat / 2145916800)
    {
        vIntDat = 2145916800 * (1 | vIntDat >> 31);
    }
    integer vIntYrs = 1970 + ((((vIntDat %= 126230400) >> 31) + vIntDat / 126230400)
                              << 2);
    vIntDat -= 126230400 * (vIntDat >> 31);
    integer vIntDys = vIntDat / 86400;
    list vLstRtn = [ vIntDat % 86400 / 3600, vIntDat % 3600 / 60,
                     vIntDat % 60 ];

    if (789 == vIntDys)
    {
        vIntYrs += 2;
        vIntDat = 2;
        vIntDys = 29;
    }
    else
    {
        vIntYrs += (vIntDys -= (vIntDys > 789)) / 365;
        vIntDys %= 365;
        vIntDys += vIntDat = 1;
        integer vIntTmp;
        while (vIntDys > (vIntTmp = (30 | (vIntDat & 1) ^ (vIntDat > 7)) -
                                    ((vIntDat == 2) << 1)))
        {
            ++vIntDat;
            vIntDys -= vIntTmp;
        }
    }
    return [ vIntYrs, vIntDat, vIntDys ] + vLstRtn;
}
//==============================================================================
// Returns a string that is the day of the week for the given date.
// vIntDate: source Unix time stamp
//==============================================================================
string uUnix2WeekdayStr(integer vIntDate)
{
    return llList2String(
        [ "Thursday", "Friday", "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday" ],
        vIntDate % 604800 / 86400 + (vIntDate >> 31));
}
//==============================================================================
// Returns a string that is the month name for the given month.
// vIntDate: source Unix time stamp
//==============================================================================
string sMonthName(integer iMonth)
{
    return llList2String(
        [ " ", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ],
        iMonth);
}
//==============================================================================
// sAddDays: Add n days then return modified unix date code
//==============================================================================
integer iAddDays(integer iDateCode, integer iNDays)
{
    integer iSecsPerDay = 86400;
    iDateCode += iNDays * iSecsPerDay;
    return iDateCode;
}
//==============================================================================
// sDateFromCode: Get string date from unix date code
//==============================================================================
string sDateFromCode(integer iDateCode)
{
    list lstDate = uUnix2StampLst(iDateCode);
    integer iYear = llList2Integer(lstDate, 0);
    integer iMonth = llList2Integer(lstDate, 1);
    integer iDay = llList2Integer(lstDate, 2);
    string sMonth = sMonthName(iMonth);
    string sLongDate = sMonth + " " + (string)iDay + ", " + (string)iYear;

    return (sLongDate);
}
// =============================================================================
// EditRacer(): Change data for a single racer
// =============================================================================
EditRacer(string sPickRacer, string sPickEdit)
{
    // DebugTrace("EditRacer: sPickRacer=" + sPickRacer + " sPickEdit=" + sPickEdit);
    // sPickRacer is first 8 digits of racer's UUID
    // sPickEdit is "Scratch", "A League", "B League", "C League", "D League"

    string sRiderKey = sGetKeyFromName(sPickRacer);

    if (sPickEdit == "Scratch")
    {
        // Remove rider entry from m_sRiderDataList
        m_sRiderDataList = sRemoveRiderEntry(sRiderKey);
        // DebugTrace("EditRacer: sRemoveRiderEntry");
    }
    else if (llSubStringIndex(sPickEdit, "League") > 0)
    {
        //  Get the entry for this rider from the m_sRiderDataList
        string sRiderEntry = sGetRiderEntry(sRiderKey);
        // DebugTrace("EditRacer: sRiderEntry=" + sRiderEntry);

        // Update the fields for the rider entry
        LoadRiderFields(sRiderEntry);
        // DebugTrace("EditRacer: LoadRiderFields");

        // Remove old rider entry from m_sRiderDataList
        m_sRiderDataList = sRemoveRiderEntry(sRiderKey);
        // DebugTrace("EditRacer: sRemoveRiderEntry");

        // Create rider entry from updated fields
        string sLeague = sPickEdit;
        m_sRiderLeague = sLeague;
        sRiderEntry = sUpdateRiderEntry(sRiderKey);
        // DebugTrace("EditRacer: UpdateRiderEntry: " + sRiderEntry);

        // Add new rider entry to the end of the data list
        m_sRiderDataList += sRiderEntry;
        SendLnkCmd("d-m_sRiderDataList", m_sRiderDataList, 0);
    }
    else
    {
        return;
    }

    // Send the modified list back to the SignupData script
    SendLnkCmd("d-m_sRiderDataList", m_sRiderDataList, 0);
    SendLnkCmd("ShowData", "", 0);
}
//==============================================================================
// sGetEntryFromName: Locate and return the data record for selected name
// If not found, return empty string
//==============================================================================
string sGetKeyFromName(string sRiderName)
{
    // Find rider name in datalist
    integer iBeg = llSubStringIndex(m_sRiderDataList, sRiderName);
    string sRiderKey;

    if (iBeg >= 0)
    {
        // Search datalist for the name
        if (iBeg < 50)
        {
            // If loc of name is < 70, it's the first record
            // First record begins at 0
            iBeg = 0; // From beg of data list
        }
        else
        {
            // Back up 50 chars and find next "|" delimiter
            iBeg -= 50; // Back up 70 chars from display name
            string sRiderList = llGetSubString(m_sRiderDataList, iBeg, -1);
            iBeg = iBeg + llSubStringIndex(sRiderList, "|") + 1; // find "|"
        }
        // Look for next "|" delimiter in datalist for end of entry
        sRiderKey = llGetSubString(m_sRiderDataList, iBeg + 1, iBeg + 8);
    }
    return sRiderKey;
}
//==============================================================================
// sGetRiderEntry: Locate and return the data record for the selected rider
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
} //==============================================================================
// RemoveRiderEntry: Remove existing rider record from the database
// =============================================================================
string sRemoveRiderEntry(string sKeyRider)
{
    string sSubDataList;
    string sRiderDataList;

    // DebugTrace("sRemoveRiderEntry " + sKeyRider);

    // Find sKeyTharl and remove racer data
    sKeyRider = llGetSubString(sKeyRider, 0, 7);
    integer iBeg = llSubStringIndex(m_sRiderDataList, sKeyRider);

    if (iBeg >= 0)
    {
        sSubDataList = llGetSubString(m_sRiderDataList, iBeg, iBeg + 170);
        integer iEnd = iBeg + llSubStringIndex(sSubDataList, "|");
        // DebugTrace("iBeg/iEnd=" + (string)iBeg + " / " + (string)iEnd);
        sRiderDataList = llDeleteSubString(m_sRiderDataList, iBeg, iEnd);
        // DebugTrace("m_sRiderDataList=[" + sRiderDataList + "]");
    }

    return sRiderDataList;
}
//==============================================================================
// sUpdateRiderEntry: Add fields to create a rider entry
// =============================================================================
string sUpdateRiderEntry(string sKeyRider)
{
    // Add fields to create a rider entry
    // DebugTrace("sUpdateRiderEntry");
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
    // DebugTrace("sAddField: " + sField + ": " + sRecord);
    return sRecord;
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
// sGetField: Get a selected field from a list, trimmed
//==============================================================================
string sGetField(list lstRiderData, integer iFieldNo)
{
    // Get the entry for this rider from the database
    string sField = llList2String(lstRiderData, iFieldNo);
    sField = llStringTrim(sField, STRING_TRIM);
    // DebugTrace("sGetField " + (string)iFieldNo + ": " + sField);
    return sField;
}
//==============================================================================
// SaveData: Send race data to local chat and to sDataRecovery
// If bEcho == TRUE then echo data to chat
//==============================================================================
SaveData(key keyDlg, integer bEcho)
{
    // For each racer, send a data line
    string sLine;
    integer iCount;
    DebugTrace("SaveData");

    DebugTrace("m_sTrackName=" + m_sTrackName);
    DebugTrace("m_sRaceDate=" + m_sRaceDate);
    DebugTrace("m_sRaceTime=" + m_sRaceTime);

    // Reset recovery data
    m_sRecoveryData = "";

    // Record new data
    SaveRecovery(keyDlg, "#%" + "========= BeginData =========", bEcho);
    SaveRecovery(keyDlg, "#%TrackName " + m_sTrackName, bEcho);
    SaveRecovery(keyDlg, "#%RaceDate " + m_sRaceDate, bEcho);
    SaveRecovery(keyDlg, "#%RaceTime " + m_sRaceTime, bEcho);
    SaveRecovery(keyDlg, "#%NLeagues " + (string)m_iNLeagues, bEcho);

    list lstEntries = llParseString2List(m_sRiderDataList, ["|"], []);
    integer iNEntries = llGetListLength(lstEntries);

    for (iCount = 0; iCount < iNEntries; ++iCount)
    {
        string sRiderEntry = llList2String(lstEntries, iCount);
        SaveRecovery(keyDlg, "#%" + sRiderEntry + "|", bEcho);
    }
    SaveRecovery(keyDlg, "#%" + "========= EndOfData =========", bEcho);

    DebugTrace(m_sRecoveryData);

    // SendLnkCmd("f-ShowData", keyDlg, 0);
    // llMessageLinked(LINK_THIS, 0, "Show Data", m_sRiderDataList);
}
// =============================================================================
// SaveRecovery: Overwrite recovery data
// =============================================================================
SaveRecovery(key keyDlg, string sText, integer bEcho)
{
    m_sRecoveryData += sText + "\n";
    if (bEcho)
    {
        llRegionSayTo(keyDlg, 0, sText);
    }
}
//==============================================================================
// RecoverData: Restore data from sDataRecovery
//==============================================================================
RecoverData(key keyDlg, integer bEcho)
{
    string sLine;
    integer iDataIndex;
    integer iCount;

    m_iRecoveryLoc = 0;
    m_sRiderDataList = "";

    list lstRecoveryList = llParseString2List(m_sRecoveryData, ["\n"], []);
    integer iNLines = llGetListLength(lstRecoveryList);
    DebugTrace("RecoverData: iNLines=" + (string)iNLines);
    sLine = llList2String(lstRecoveryList, 3);
    DebugTrace("line 3: " + sLine);
    sLine = llList2String(lstRecoveryList, 6);
    DebugTrace("line 6: " + sLine);
    DisplayMemory(keyDlg);

    for (iCount = 1; iCount <= 5; iCount++)
    {
        DebugTrace("Test " + (string)iCount);
    }
    // process for up to 100 lines
    for (iCount = 0; iCount < iNLines; iCount++)
    {
        DebugTrace("========== line " + (string)iCount);

        sLine = llList2String(lstRecoveryList, iCount);
        DebugTrace((string)iCount + ". " + sLine);
        iDataIndex = llSubStringIndex(sLine, "#%");

        if (iDataIndex < 0)
        {
            // Do nothing: An extraneous line was inserted
        }
        else if (llSubStringIndex(sLine, "BeginData") >= 0)
        {
            llRegionSayTo(m_keyDlg, PUBLIC_CHANNEL, "beginning recovery...");
            // Do nothing: Data begins on next line
        }
        else if (llSubStringIndex(sLine, "EndOfData") >= 0)
        {
            // Send all collected data
            TransferRaceData();
            llRegionSayTo(m_keyDlg, PUBLIC_CHANNEL, "Recovery complete.");
            jump EndOfList;
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
    @EndOfList;
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
// TransferRaceData: Send race data to the Signup script
//==============================================================================
TransferRaceData()
{
    m_sRaceDayTime = m_sRaceDate + " at " + m_sRaceTime;
    llMessageLinked(LINK_THIS, m_iNLeagues, "m_iNLeagues", "");
    llMessageLinked(LINK_THIS, 0, "m_sTrackName", m_sTrackName);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDate", m_sRaceDate);
    llMessageLinked(LINK_THIS, 0, "m_sRaceTime", m_sRaceTime);
    llMessageLinked(LINK_THIS, 0, "m_sRaceDayTime", m_sRaceDayTime);
    llMessageLinked(LINK_THIS, 0, "m_sRiderDataList", m_sRiderDataList);
    llMessageLinked(LINK_THIS, 0, "EndOfData", m_keyDlg);
}
// =============================================================================
// LnkMsgResponse
// =============================================================================
LnkMsgResponse(string sCmd, key keyData, integer iNum)
{
    // Set debug; placed before debug can echo
    if (sCmd == "m_bDebug")
    {
        m_bDebug = iNum;
        return;
    }

    string sData = (string)keyData;
    key keyDlg = keyData;
    DebugTrace("LnkRsp: sCmd=" + sCmd + " sData=" + sData);
    // DebugTrace("LnkRsp: " + sCmd + "," + sData + "," + (string)iNum);

    if (llSubStringIndex(sCmd, "m_") == 0)
    {
        // Data Settings
        if (sCmd == "m_sTrackName")
        {
            m_sTrackName = sData;
        }
        else if (sCmd == "m_iNLeagues")
        {
            m_iNLeagues = iNum;
        }
        else if (sCmd == "m_sRaceDayTime")
        {
            m_sRaceDayTime = sData;
        }
        else if (sCmd == "m_sRaceDate")
        {
            m_sRaceDate = sData;
        }
        else if (sCmd == "m_sRaceTime")
        {
            m_sRaceTime = sData;
        }
        else if (sCmd == "m_sRiderDataList")
        {
            m_sRiderDataList = sData;
        }
    }
    else
    {
        // Operations
        if (sCmd == "DisplayMemory")
        {
            DisplayMemory(keyDlg);
        }
        else if (sCmd == "SetNextRaceDay")
        {
            SetNextRaceDay();
        }
        else if (sCmd == "EditRacer")
        {
            list lstParams = llParseString2List(sData, ["|"], []);
            string sPickRacer = llList2String(lstParams, 0);
            string sPickEdit = llList2String(lstParams, 1);
            // DebugTrace("sPickRacer=" + sPickRacer + " sPickEdit=" + sPickEdit);
            EditRacer(sPickRacer, sPickEdit);
        }
        else if (sCmd == "SaveData")
        {
            key keyDlg = sData;
            SaveData(keyDlg, TRUE);
        }
        else if (sCmd == "RecoverData")
        {
            key keyDlg = sData;
            RecoverData(keyDlg, TRUE);
        }
        else if (sCmd == "ShowRecovery")
        {
            key keyDlg = sData;
            llRegionSayTo(keyDlg, PUBLIC_CHANNEL, m_sRecoveryData);
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
// sSelectMsg: select only messages with no prefex or m_sMyPrefix (h-)
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
        llOwnerSay("[SignupHelper " + (string)llGetFreeMemory() + "] " + sMsg);
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
        DisplayMemory("");
    }
    //======================================
    link_message(integer iSender, integer iNum, string sCmd, key keyData)
    {
        // Deselect messages with prefix to other modules
        sCmd = sSelectMsg(sCmd);

        // sSelectMsg returns "" if command is not for this module
        if (sCmd == "")
        {
            return;
        }

        // Process all messages to me and to all
        LnkMsgResponse(sCmd, keyData, iNum);
    }
    // =========================================================================
}
// =============================================================================
 