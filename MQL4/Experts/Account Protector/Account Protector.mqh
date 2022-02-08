//+------------------------------------------------------------------+
//|                                            Account Protector.mqh |
//|                             Copyright © 2017-2022, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#include "Defines.mqh"
#include <WinUser32.mqh>
#include <Arrays\ArrayLong.mqh>

#import "user32.dll"
int GetAncestor(int, int);
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAccountProtector : public CAppDialog
{
private:
    // Tab Buttons
    CButton         m_BtnTabMain, m_BtnTabFilters, m_BtnTabConditions, m_BtnTabActions;

    // Main Tab - Labels
    CLabel          m_LblStatus, m_LblSpread, m_LblTimeLeft, m_LblSnapEquity, m_LblSnapMargin, m_LblURL, m_LblCurrentEquityStopLoss, m_LblDayOfWeek;
    // Main Tab - CheckBoxes
    CCheckBox       m_ChkCountCommSwaps, m_ChkUseTimer, m_ChkTrailingStart, m_ChkTrailingStep, m_ChkBreakEven, m_ChkBreakEvenExtra, m_ChkEquityTrailingStop;
    // Main Tab - Edits
    CEdit           m_EdtTimer, m_EdtTrailingStart, m_EdtTrailingStep, m_EdtBreakEven, m_EdtBreakEvenExtra, m_EdtEquityTrailingStop;
    // MainTab - Radio Group
    CRadioGroup     m_RgpTimeType;
    // Main Tab - Buttons
    CButton         m_BtnNewSnapEquity, m_BtnResetEquityStopLoss, m_BtnNewSnapMargin, m_BtnEmergency, m_BtnDayOfWeek;

    // Filters Tab - Labels
    CLabel          m_LblMagics, m_LblOrderCommentary, m_LblInstruments;
    // Filters Tab - CheckBoxes
    CCheckBox       m_ChkExcludeMagics, m_ChkIgnoreLossTrades, m_ChkIgnoreProfitTrades;
    // Filters Tab - Edits
    CEdit           m_EdtMagics, m_EdtOrderCommentary, m_EdtInstruments;
    // Filters Tab - Buttons
    CButton         m_BtnResetFilters;
    // Filters Tab - Radio Group
    CRadioGroup     m_RgpInstrumentFilter;
    // Filters Tab - ComboBox
    CComboBox       m_CbxOrderCommentaryCondition;

    // Conditions Tab - CheckBoxes
    CCheckBox       m_ChkLossPerBalance, m_ChkLossQuanUnits, m_ChkLossPoints, m_ChkProfPerBalance, m_ChkProfQuanUnits, m_ChkProfPoints;
    CCheckBox       m_ChkLossPerBalanceReverse, m_ChkLossQuanUnitsReverse, m_ChkLossPointsReverse, m_ChkProfPerBalanceReverse, m_ChkProfQuanUnitsReverse, m_ChkProfPointsReverse;
    CCheckBox       m_ChkEquityLessUnits, m_ChkEquityGrUnits, m_ChkEquityLessPerSnap, m_ChkEquityGrPerSnap, m_ChkEquityMinusSnapshot, m_ChkSnapshotMinusEquity;
    CCheckBox       m_ChkMarginLessUnits, m_ChkMarginGrUnits, m_ChkMarginLessPerSnap, m_ChkMarginGrPerSnap;
    CCheckBox       m_ChkPriceGE, m_ChkPriceLE, m_ChkMarginLevelGE, m_ChkMarginLevelLE, m_ChkSpreadGE, m_ChkSpreadLE;
    CCheckBox       m_ChkDailyProfitLossUnitsGE, m_ChkDailyProfitLossUnitsLE, m_ChkDailyProfitLossPointsGE, m_ChkDailyProfitLossPointsLE, m_ChkDailyProfitLossPercGE, m_ChkDailyProfitLossPercLE;
    // Conditions Tab - Edits
    CEdit           m_EdtLossPerBalance, m_EdtLossQuanUnits, m_EdtLossPoints, m_EdtProfPerBalance, m_EdtProfQuanUnits, m_EdtProfPoints;
    CEdit           m_EdtLossPerBalanceReverse, m_EdtLossQuanUnitsReverse, m_EdtLossPointsReverse, m_EdtProfPerBalanceReverse, m_EdtProfQuanUnitsReverse, m_EdtProfPointsReverse;
    CEdit           m_EdtEquityLessUnits, m_EdtEquityGrUnits, m_EdtEquityLessPerSnap, m_EdtEquityGrPerSnap, m_EdtEquityMinusSnapshot, m_EdtSnapshotMinusEquity;
    CEdit           m_EdtMarginLessUnits, m_EdtMarginGrUnits, m_EdtMarginLessPerSnap, m_EdtMarginGrPerSnap;
    CEdit           m_EdtPriceGE, m_EdtPriceLE, m_EdtMarginLevelGE, m_EdtMarginLevelLE, m_EdtSpreadGE, m_EdtSpreadLE;
    CEdit           m_EdtDailyProfitLossUnitsGE, m_EdtDailyProfitLossUnitsLE, m_EdtDailyProfitLossPointsGE, m_EdtDailyProfitLossPointsLE, m_EdtDailyProfitLossPercGE, m_EdtDailyProfitLossPercLE;

    // Actions Tab - Labels
    CLabel          m_LblClosePosSuffix, m_LblClosePosPostfix;
    // Actions Tab - CheckBoxes
    CCheckBox       m_ChkClosePos, m_ChkDeletePend, m_ChkDisAuto, m_ChkSendMails, m_ChkSendNotif, m_ChkClosePlatform, m_ChkEnableAuto, m_ChkRecaptureSnapshots;
    // Actions Tab - Edits
    CEdit           m_EdtClosePercentage;
    // Actions Tab - Buttons
    CButton         m_BtnPositionStatus;

    string          m_FileName;
    int             LogFile, QuantityClosedMarketOrders, QuantityDeletedPendingOrders, magic_array_counter, MagicNumbers_array[], instruments_array_counter;
    string          Instruments_array[];
    bool            IsANeedToContinueClosingOrders, IsANeedToContinueDeletingPendingOrders;
    bool            WasAutoTradingDisabled, WasMailSent, WasNotificationSent, WasPlatformClosed, WasAutoTradingEnabled, WasRecapturedSnapshots;
    double          m_DPIScale;
    bool            NoPanelMaximization; // Crutch variable to prevent panel maximization when Maximize() is called at the indicator's initialization.
    CArrayLong     *PartiallyClosedOrders; // Stores order tickets that have been partially closed by Eliminate_Orders().
    double          PositionsByProfit[][2]; // Stores position (order) ticket and its floating profit/loss. Gets filled and sorted when some condition is met and actions are about to get triggered.
    ENUM_CONDITIONS TriggeredCondition; // Checked for position array sorting (when optimal) and for partial position closure cancellation when UseTotalVolume is enabled.
    double          ClosedVolume; // How much of the volume has already been closed - for partial closure when UseTotalVolume == true.
    double          TotalVolume; // Store the total volume of filtered trades.

public:
                    CAccountProtector(void);
                   ~CAccountProtector(void)
    {
        delete PartiallyClosedOrders;
    };

    virtual bool Create(const long chart, const string name, const int subwin, const int x1, const int y1);
    virtual void Destroy();
    void         ShowSelectedTab();
    bool         SaveSettingsOnDisk();
    bool         LoadSettingsFromDisk();
    bool         DeleteSettingsFile();
    virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
    bool         RefreshValues();
    void         RefreshPanelControls();
    void         CheckAllConditions();
    void         Trailing();
    void         EquityTrailing();
    void         MoveToBreakEven();
    void         Logging(const string message);
    bool         SilentLogging;
    void         Logging_Current_Settings();
    void         HideShowMaximize(bool max);

    // Remember the panel's location to have the same location for minimized and maximized states.
    int          remember_top, remember_left;

private:
    bool         CreateObjects();
    bool         InitObjects();
    void         MoveAndResize();
    bool         ButtonCreate     (CButton&     Btn, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
    bool         CheckBoxCreate   (CCheckBox&   Chk, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
    bool         EditCreate       (CEdit&       Edt, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
    bool         LabelCreate      (CLabel&      Lbl, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string Text);
    bool         RadioGroupCreate (CRadioGroup& Rgp, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string &Text[]);
    bool         ComboBoxCreate   (CComboBox&   Cbx, const int X1, const int Y1, const int X2, const int Y2, const string Name, const string &Text[]);
    void         ShowMain();
    void         ShowFilters();
    void         ShowConditions();
    void         ShowActions();
    void         HideMain();
    void         HideFilters();
    void         HideConditions();
    void         HideActions();
    virtual void Maximize();
    virtual void Minimize();
    void         SeekAndDestroyDuplicatePanels();

    void         Check_Status();
    bool         No_Condition();
    bool         No_Action();
    string       NewTime();
    bool         CheckFilterSymbol(const string order_symbol);
    bool         CheckFilterComment(const string order_comment);
    bool         CheckFilterMagic(const int order_magic, const int j);
    bool         CheckFilterLossProfit(const double order_profit);
    void         Close_All_Positions();
    void         Delete_All_Pending_Orders();
    int          Eliminate_Current_Order(const int ticket);
    void         Trigger_Actions(const string title);
    void         Logging_Condition_Is_Met();
    void         PrepareSubjectBody(string &subject, string &body, const string title, const datetime timestamp, const int pos_closed, const int pend_deleted, const bool autotrade_dis, const bool push_sent, const bool mail_sent, const bool platf_closed, const bool autotrade_enabled, const bool snapshots_recaptured, const bool short_body = false);
    void         SendMailFunction(string subject, string body);
    void         SendNotificationFunction(string subject, string body);
    template<typename T>
    void         CheckOneCondition(T &SettingsEditValue, bool &SettingsCheckboxValue, const string EventDescription, const ENUM_CONDITIONS triggered_condition = Other_condition);
    void         ProcessMagicNumbers();
    void         ProcessInstruments();
    bool         IsDouble(const string value);
    bool         IsInteger(const string value);
    double       CalculateOrderLots(const double lots, const string symbol);

    // Event handlers
    void OnClickBtnTabMain();
    void OnClickBtnTabFilters();
    void OnClickBtnTabConditions();
    void OnClickBtnTabActions();
    void OnChangeChkCountCommSwaps();
    void OnChangeChkUseTimer();
    void OnEndEditTimer();
    void OnChangeRgpTimeType();
    void OnChangeChkTrailingStart();
    void OnChangeChkTrailingStep();
    void OnChangeChkBreakEven();
    void OnChangeChkBreakEvenExtra();
    void OnEndEditTrailingStart();
    void OnEndEditTrailingStep();
    void OnEndEditBreakEven();
    void OnEndEditBreakEvenExtra();
    void OnChangeChkEquityTrailingStop();
    void OnEndEditEquityTrailingStop();
    void OnClickBtnResetEquityStopLoss();
    void OnClickBtnNewSnapEquity();
    void OnClickBtnNewSnapMargin();
    void OnChangeCbxOrderCommentaryCondition();
    void OnEndEditOrderCommentary();
    void OnEndEditMagics();
    void OnChangeChkExcludeMagics();
    void OnChangeRgpInstrumentFilter();
    void OnEndEditInstruments();
    void OnChangeChkIgnoreLossTrades();
    void OnChangeChkIgnoreProfitTrades();
    void OnClickBtnResetFilters();
    void OnChangeChkLossPerBalance();
    void OnChangeChkLossPerBalanceReverse();
    void OnChangeChkLossQuanUnits();
    void OnChangeChkLossQuanUnitsReverse();
    void OnChangeChkLossPoints();
    void OnChangeChkLossPointsReverse();
    void OnChangeChkProfPerBalance();
    void OnChangeChkProfPerBalanceReverse();
    void OnChangeChkProfQuanUnits();
    void OnChangeChkProfQuanUnitsReverse();
    void OnChangeChkProfPoints();
    void OnChangeChkProfPointsReverse();
    void OnChangeChkEquityLessUnits();
    void OnChangeChkEquityGrUnits();
    void OnChangeChkEquityLessPerSnap();
    void OnChangeChkEquityGrPerSnap();
    void OnChangeChkEquityMinusSnapshot();
    void OnChangeChkSnapshotMinusEquity();
    void OnChangeChkMarginLessUnits();
    void OnChangeChkMarginGrUnits();
    void OnChangeChkMarginLessPerSnap();
    void OnChangeChkMarginGrPerSnap();
    void OnChangeChkPriceGE();
    void OnChangeChkPriceLE();
    void OnChangeChkMarginLevelGE();
    void OnChangeChkMarginLevelLE();
    void OnChangeChkSpreadGE();
    void OnChangeChkSpreadLE();
    void OnChangeChkDailyProfitLossUnitsGE();
    void OnChangeChkDailyProfitLossUnitsLE();
    void OnChangeChkDailyProfitLossPointsGE();
    void OnChangeChkDailyProfitLossPointsLE();
    void OnChangeChkDailyProfitLossPercGE();
    void OnChangeChkDailyProfitLossPercLE();
    void OnChangeChkClosePos();
    void OnChangeChkDeletePend();
    void OnChangeChkDisAuto();
    void OnChangeChkSendMails();
    void OnChangeChkSendNotif ();
    void OnChangeChkClosePlatform();
    void OnChangeChkEnableAuto();
    void OnChangeChkRecaptureSnapshots();
    void OnEndEditLossPerBalance();
    void OnEndEditLossPerBalanceReverse();
    void OnEndEditLossQuanUnits();
    void OnEndEditLossQuanUnitsReverse();
    void OnEndEditLossPoints();
    void OnEndEditLossPointsReverse();
    void OnEndEditProfPerBalance();
    void OnEndEditProfPerBalanceReverse();
    void OnEndEditProfQuanUnits();
    void OnEndEditProfQuanUnitsReverse();
    void OnEndEditProfPoints();
    void OnEndEditProfPointsReverse();
    void OnEndEditEquityLessUnits();
    void OnEndEditEquityGrUnits();
    void OnEndEditEquityLessPerSnap();
    void OnEndEditEquityGrPerSnap();
    void OnEndEditEquityMinusSnapshot();
    void OnEndEditSnapshotMinusEquity();
    void OnEndEditMarginLessUnits();
    void OnEndEditMarginGrUnits();
    void OnEndEditMarginLessPerSnap();
    void OnEndEditMarginGrPerSnap();
    void OnEndEditPriceGE();
    void OnEndEditPriceLE();
    void OnEndEditMarginLevelGE();
    void OnEndEditMarginLevelLE();
    void OnEndEditSpreadGE();
    void OnEndEditSpreadLE();
    void OnEndEditDailyProfitLossUnitsGE();
    void OnEndEditDailyProfitLossUnitsLE();
    void OnEndEditDailyProfitLossPointsGE();
    void OnEndEditDailyProfitLossPointsLE();
    void OnEndEditDailyProfitLossPercGE();
    void OnEndEditDailyProfitLossPercLE();
    void OnEndEditClosePercentage();
    void OnClickBtnEmergency();
    void OnClickBtnDayOfWeek();
    void OnClickBtnPositionStatus();

    // Supplementary functions:
    void         CheckboxChangeMain(bool& SettingsCheckboxValue, CCheckBox& CheckBox);
    void         CheckboxChangeConditions(bool& SettingsCheckboxValue, CCheckBox& CheckBox);
    void         CheckboxChangeActions(bool& SettingsCheckboxValue, CCheckBox& CheckBox);
    template<typename T>
    void         EditChangeConditions(T& SettingsEditValue, CEdit& Edit, const string FieldName, const double RangeMaximum = 0);
    void         EditChangeMain(int& SettingsEditValue, CEdit& Edit, const string FieldName);
    void         RefreshConditions(const bool SettingsCheckBoxValue, const double SettingsEditValue, CCheckBox& CheckBox, CEdit& Edit, const int decimal_places);
    void         UpdateEquitySnapshot();
    void         UpdateMarginSnapshot();
};

// Event Map
EVENT_MAP_BEGIN(CAccountProtector)
ON_EVENT(ON_CLICK, m_BtnTabMain, OnClickBtnTabMain)
ON_EVENT(ON_CLICK, m_BtnTabFilters, OnClickBtnTabFilters)
ON_EVENT(ON_CLICK, m_BtnTabConditions, OnClickBtnTabConditions)
ON_EVENT(ON_CLICK, m_BtnTabActions, OnClickBtnTabActions)
ON_EVENT(ON_CLICK, m_BtnDayOfWeek, OnClickBtnDayOfWeek)
ON_EVENT(ON_CHANGE, m_ChkCountCommSwaps, OnChangeChkCountCommSwaps)
ON_EVENT(ON_CHANGE, m_ChkUseTimer, OnChangeChkUseTimer)
ON_EVENT(ON_END_EDIT, m_EdtTimer, OnEndEditTimer)
ON_EVENT(ON_CHANGE, m_RgpTimeType, OnChangeRgpTimeType)
ON_EVENT(ON_CHANGE, m_ChkTrailingStart, OnChangeChkTrailingStart)
ON_EVENT(ON_CHANGE, m_ChkTrailingStep, OnChangeChkTrailingStep)
ON_EVENT(ON_CHANGE, m_ChkBreakEven, OnChangeChkBreakEven)
ON_EVENT(ON_CHANGE, m_ChkBreakEvenExtra, OnChangeChkBreakEvenExtra)
ON_EVENT(ON_END_EDIT, m_EdtTrailingStart, OnEndEditTrailingStart)
ON_EVENT(ON_END_EDIT, m_EdtTrailingStep, OnEndEditTrailingStep)
ON_EVENT(ON_END_EDIT, m_EdtBreakEven, OnEndEditBreakEven)
ON_EVENT(ON_END_EDIT, m_EdtBreakEvenExtra, OnEndEditBreakEvenExtra)
ON_EVENT(ON_CHANGE, m_ChkEquityTrailingStop, OnChangeChkEquityTrailingStop)
ON_EVENT(ON_END_EDIT, m_EdtEquityTrailingStop, OnEndEditEquityTrailingStop)
ON_EVENT(ON_CLICK, m_BtnResetEquityStopLoss, OnClickBtnResetEquityStopLoss)
ON_EVENT(ON_CLICK, m_BtnNewSnapEquity, OnClickBtnNewSnapEquity)
ON_EVENT(ON_CLICK, m_BtnNewSnapMargin, OnClickBtnNewSnapMargin)
ON_EVENT(ON_CHANGE, m_CbxOrderCommentaryCondition, OnChangeCbxOrderCommentaryCondition)
ON_EVENT(ON_END_EDIT, m_EdtOrderCommentary, OnEndEditOrderCommentary)
ON_EVENT(ON_END_EDIT, m_EdtMagics, OnEndEditMagics)
ON_EVENT(ON_CHANGE, m_ChkExcludeMagics, OnChangeChkExcludeMagics)
ON_EVENT(ON_CHANGE, m_RgpInstrumentFilter, OnChangeRgpInstrumentFilter)
ON_EVENT(ON_END_EDIT, m_EdtInstruments, OnEndEditInstruments)
ON_EVENT(ON_CHANGE, m_ChkIgnoreLossTrades, OnChangeChkIgnoreLossTrades)
ON_EVENT(ON_CHANGE, m_ChkIgnoreProfitTrades, OnChangeChkIgnoreProfitTrades)
ON_EVENT(ON_CLICK, m_BtnResetFilters, OnClickBtnResetFilters)
ON_EVENT(ON_CHANGE, m_ChkLossPerBalance, OnChangeChkLossPerBalance)
ON_EVENT(ON_CHANGE, m_ChkLossPerBalanceReverse, OnChangeChkLossPerBalanceReverse)
ON_EVENT(ON_CHANGE, m_ChkLossQuanUnits, OnChangeChkLossQuanUnits)
ON_EVENT(ON_CHANGE, m_ChkLossQuanUnitsReverse, OnChangeChkLossQuanUnitsReverse)
ON_EVENT(ON_CHANGE, m_ChkLossPoints, OnChangeChkLossPoints)
ON_EVENT(ON_CHANGE, m_ChkLossPointsReverse, OnChangeChkLossPointsReverse)
ON_EVENT(ON_CHANGE, m_ChkProfPerBalance, OnChangeChkProfPerBalance)
ON_EVENT(ON_CHANGE, m_ChkProfPerBalanceReverse, OnChangeChkProfPerBalanceReverse)
ON_EVENT(ON_CHANGE, m_ChkProfQuanUnits, OnChangeChkProfQuanUnits)
ON_EVENT(ON_CHANGE, m_ChkProfQuanUnitsReverse, OnChangeChkProfQuanUnitsReverse)
ON_EVENT(ON_CHANGE, m_ChkProfPoints, OnChangeChkProfPoints)
ON_EVENT(ON_CHANGE, m_ChkProfPointsReverse, OnChangeChkProfPointsReverse)
ON_EVENT(ON_CHANGE, m_ChkEquityLessUnits, OnChangeChkEquityLessUnits)
ON_EVENT(ON_CHANGE, m_ChkEquityGrUnits, OnChangeChkEquityGrUnits)
ON_EVENT(ON_CHANGE, m_ChkEquityLessPerSnap, OnChangeChkEquityLessPerSnap)
ON_EVENT(ON_CHANGE, m_ChkEquityGrPerSnap, OnChangeChkEquityGrPerSnap)
ON_EVENT(ON_CHANGE, m_ChkEquityMinusSnapshot, OnChangeChkEquityMinusSnapshot)
ON_EVENT(ON_CHANGE, m_ChkSnapshotMinusEquity, OnChangeChkSnapshotMinusEquity)
ON_EVENT(ON_CHANGE, m_ChkMarginLessUnits, OnChangeChkMarginLessUnits)
ON_EVENT(ON_CHANGE, m_ChkMarginGrUnits, OnChangeChkMarginGrUnits)
ON_EVENT(ON_CHANGE, m_ChkMarginLessPerSnap, OnChangeChkMarginLessPerSnap)
ON_EVENT(ON_CHANGE, m_ChkMarginGrPerSnap, OnChangeChkMarginGrPerSnap)
ON_EVENT(ON_CHANGE, m_ChkPriceGE, OnChangeChkPriceGE)
ON_EVENT(ON_CHANGE, m_ChkPriceLE, OnChangeChkPriceLE)
ON_EVENT(ON_CHANGE, m_ChkMarginLevelGE, OnChangeChkMarginLevelGE)
ON_EVENT(ON_CHANGE, m_ChkMarginLevelLE, OnChangeChkMarginLevelLE)
ON_EVENT(ON_CHANGE, m_ChkSpreadGE, OnChangeChkSpreadGE)
ON_EVENT(ON_CHANGE, m_ChkSpreadLE, OnChangeChkSpreadLE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossUnitsGE, OnChangeChkDailyProfitLossUnitsGE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossUnitsLE, OnChangeChkDailyProfitLossUnitsLE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossPointsGE, OnChangeChkDailyProfitLossPointsGE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossPointsLE, OnChangeChkDailyProfitLossPointsLE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossPercGE, OnChangeChkDailyProfitLossPercGE)
ON_EVENT(ON_CHANGE, m_ChkDailyProfitLossPercLE, OnChangeChkDailyProfitLossPercLE)
ON_EVENT(ON_CHANGE, m_ChkClosePos, OnChangeChkClosePos)
ON_EVENT(ON_CLICK, m_BtnPositionStatus, OnClickBtnPositionStatus)
ON_EVENT(ON_CHANGE, m_ChkDeletePend, OnChangeChkDeletePend)
ON_EVENT(ON_CHANGE, m_ChkDisAuto, OnChangeChkDisAuto)
ON_EVENT(ON_CHANGE, m_ChkSendMails, OnChangeChkSendMails)
ON_EVENT(ON_CHANGE, m_ChkSendNotif, OnChangeChkSendNotif)
ON_EVENT(ON_CHANGE, m_ChkClosePlatform, OnChangeChkClosePlatform)
ON_EVENT(ON_CHANGE, m_ChkEnableAuto, OnChangeChkEnableAuto)
ON_EVENT(ON_CHANGE, m_ChkRecaptureSnapshots, OnChangeChkRecaptureSnapshots)
ON_EVENT(ON_END_EDIT, m_EdtLossPerBalance, OnEndEditLossPerBalance)
ON_EVENT(ON_END_EDIT, m_EdtLossPerBalanceReverse, OnEndEditLossPerBalanceReverse)
ON_EVENT(ON_END_EDIT, m_EdtLossQuanUnits, OnEndEditLossQuanUnits)
ON_EVENT(ON_END_EDIT, m_EdtLossQuanUnitsReverse, OnEndEditLossQuanUnitsReverse)
ON_EVENT(ON_END_EDIT, m_EdtLossPoints, OnEndEditLossPoints)
ON_EVENT(ON_END_EDIT, m_EdtLossPointsReverse, OnEndEditLossPointsReverse)
ON_EVENT(ON_END_EDIT, m_EdtProfPerBalance, OnEndEditProfPerBalance)
ON_EVENT(ON_END_EDIT, m_EdtProfPerBalanceReverse, OnEndEditProfPerBalanceReverse)
ON_EVENT(ON_END_EDIT, m_EdtProfQuanUnits, OnEndEditProfQuanUnits)
ON_EVENT(ON_END_EDIT, m_EdtProfQuanUnitsReverse, OnEndEditProfQuanUnitsReverse)
ON_EVENT(ON_END_EDIT, m_EdtProfPoints, OnEndEditProfPoints)
ON_EVENT(ON_END_EDIT, m_EdtProfPointsReverse, OnEndEditProfPointsReverse)
ON_EVENT(ON_END_EDIT, m_EdtEquityLessUnits, OnEndEditEquityLessUnits)
ON_EVENT(ON_END_EDIT, m_EdtEquityGrUnits, OnEndEditEquityGrUnits)
ON_EVENT(ON_END_EDIT, m_EdtEquityLessPerSnap, OnEndEditEquityLessPerSnap)
ON_EVENT(ON_END_EDIT, m_EdtEquityGrPerSnap, OnEndEditEquityGrPerSnap)
ON_EVENT(ON_END_EDIT, m_EdtEquityMinusSnapshot, OnEndEditEquityMinusSnapshot)
ON_EVENT(ON_END_EDIT, m_EdtSnapshotMinusEquity, OnEndEditSnapshotMinusEquity)
ON_EVENT(ON_END_EDIT, m_EdtMarginLessUnits, OnEndEditMarginLessUnits)
ON_EVENT(ON_END_EDIT, m_EdtMarginGrUnits, OnEndEditMarginGrUnits)
ON_EVENT(ON_END_EDIT, m_EdtMarginLessPerSnap, OnEndEditMarginLessPerSnap)
ON_EVENT(ON_END_EDIT, m_EdtMarginGrPerSnap, OnEndEditMarginGrPerSnap)
ON_EVENT(ON_END_EDIT, m_EdtPriceGE, OnEndEditPriceGE)
ON_EVENT(ON_END_EDIT, m_EdtPriceLE, OnEndEditPriceLE)
ON_EVENT(ON_END_EDIT, m_EdtMarginLevelGE, OnEndEditMarginLevelGE)
ON_EVENT(ON_END_EDIT, m_EdtMarginLevelLE, OnEndEditMarginLevelLE)
ON_EVENT(ON_END_EDIT, m_EdtSpreadGE, OnEndEditSpreadGE)
ON_EVENT(ON_END_EDIT, m_EdtSpreadLE, OnEndEditSpreadLE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossUnitsGE, OnEndEditDailyProfitLossUnitsGE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossUnitsLE, OnEndEditDailyProfitLossUnitsLE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossPointsGE, OnEndEditDailyProfitLossPointsGE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossPointsLE, OnEndEditDailyProfitLossPointsLE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossPercGE, OnEndEditDailyProfitLossPercGE)
ON_EVENT(ON_END_EDIT, m_EdtDailyProfitLossPercLE, OnEndEditDailyProfitLossPercLE)
ON_EVENT(ON_END_EDIT, m_EdtClosePercentage, OnEndEditClosePercentage)
ON_EVENT(ON_CLICK, m_BtnEmergency, OnClickBtnEmergency)
EVENT_MAP_END(CAppDialog)

//+-------------------+
//| Class constructor |
//+-------------------+
CAccountProtector::CAccountProtector()
{
    m_FileName = "AP_" + IntegerToString(ChartID()) + ".txt";
    LogFile = -1;
    QuantityClosedMarketOrders = 0;
    QuantityDeletedPendingOrders = 0;
    IsANeedToContinueClosingOrders = false;
    IsANeedToContinueDeletingPendingOrders = false;
    SilentLogging = false;
    WasAutoTradingDisabled = false;
    WasMailSent = false;
    WasNotificationSent = false;
    WasPlatformClosed = false;
    WasAutoTradingEnabled = false;
    WasRecapturedSnapshots = false;
    NoPanelMaximization = false;
    remember_left = -1;
    remember_top = -1;
    PartiallyClosedOrders = new CArrayLong();
    TriggeredCondition = Other_condition;
}

//+--------+
//| Button |
//+--------+
bool CAccountProtector::ButtonCreate(CButton &Btn, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
    if (!Btn.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Btn))                                                              return false;
    if (!Btn.Text(Text))                                                        return false;

    return true;
}

//+----------+
//| Checkbox |
//+----------+
bool CAccountProtector::CheckBoxCreate(CCheckBox &Chk, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
    if (!Chk.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Chk))                                                              return false;
    if (!Chk.Text(Text))                                                        return false;

    return true;
}

//+------+
//| Edit |
//+------+
bool CAccountProtector::EditCreate(CEdit &Edt, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
    if (!Edt.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Edt))                                                              return false;
    if (!Edt.Text(Text))                                                        return false;

    return true;
}

//+-------+
//| Label |
//+-------+
bool CAccountProtector::LabelCreate(CLabel &Lbl, int X1, int Y1, int X2, int Y2, string Name, string Text)
{
    if (!Lbl.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Lbl))                                                              return false;
    if (!Lbl.Text(Text))                                                        return false;

    return true;
}

//+------------+
//| RadioGroup |
//+------------+
bool CAccountProtector::RadioGroupCreate(CRadioGroup &Rgp, int X1, int Y1, int X2, int Y2, string Name, const string &Text[])
{
    if (!Rgp.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Rgp))                                                              return false;

    int size = ArraySize(Text);
    for (int i = 0; i < size; i++)
    {
        if (!Rgp.AddItem(Text[i], i))                                                            return false;
    }

    return true;
}

//+----------+
//| ComboBox |
//+----------+
bool CAccountProtector::ComboBoxCreate(CComboBox &Cbx, int X1, int Y1, int X2, int Y2, string Name, const string &Text[])
{
    if (!Cbx.Create(m_chart_id, m_name + Name, m_subwin, X1, Y1, X2, Y2))       return false;
    if (!Add(Cbx))                                                              return false;

    int size = ArraySize(Text);
    Cbx.ListViewItems(size);
    for (int i = 0; i < size; i++)
    {
        if (!Cbx.AddItem(Text[i], i))                                                            return false;
    }

    return true;
}

//+-----------------------+
//| Create a panel object |
//+-----------------------+
bool CAccountProtector::Create(const long chart, const string name, const int subwin, const int x1, const int y1)
{
    double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
    m_DPIScale = screen_dpi / 96.0;

    int x2 = x1 + (int)MathRound(390 * m_DPIScale);
    int y2 = y1 + (int)MathRound(300 * m_DPIScale);

    if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))               return false;
    if (!CreateObjects())                                                         return false;
    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::Destroy()
{
    m_chart.Detach();
// Call parent destroy.
    CDialog::Destroy();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAccountProtector::CreateObjects()
{
    int row_start = (int)MathRound(10 * m_DPIScale);
    int element_height = (int)MathRound(20 * m_DPIScale);
    int v_spacing = (int)MathRound(4 * m_DPIScale);
    int h_spacing = (int)MathRound(10 * m_DPIScale);

    int tab_button_width = (int)MathRound(80 * m_DPIScale);
    int tab_button_spacing = (int)MathRound(10 * m_DPIScale);

    int normal_label_width = (int)MathRound(108 * m_DPIScale);
    int normal_edit_width = (int)MathRound(85 * m_DPIScale);
    int narrow_label_width = (int)MathRound(85 * m_DPIScale);
    int narrow_edit_width = (int)MathRound(75 * m_DPIScale);
    int narrowest_edit_width = (int)MathRound(55 * m_DPIScale);
    int shortest_edit_width = (int)MathRound(35 * m_DPIScale);
    int timer_width = (int)MathRound(50 * m_DPIScale);
    int timer_radio_width = (int)MathRound(100 * m_DPIScale);
    int snap_button_width = (int)MathRound(170 * m_DPIScale);

    int first_column_start = (int)MathRound(15 * m_DPIScale);
    int timer_label_start = first_column_start + (int)MathRound(255 * m_DPIScale);
    int second_column_start = first_column_start + (int)MathRound(113 * m_DPIScale);
    int second_column_magic_start = second_column_start - (int)MathRound(15 * m_DPIScale);
    int second_column_magic_end = second_column_magic_start + (int)MathRound(180 * m_DPIScale);
    int second_column_main_start = second_column_start + (int)MathRound(40 * m_DPIScale);
    int third_column_start = second_column_start + (int)MathRound(92 * m_DPIScale);
    int third_column_main_start = third_column_start + (int)MathRound(20 * m_DPIScale);
    int order_commentary_start = third_column_start - (int)MathRound(12 * m_DPIScale);
    int third_column_magic_start = second_column_magic_end + (int)MathRound(5 * m_DPIScale);
    int last_input_start = first_column_start + (int)MathRound(290 * m_DPIScale);
    int last_input_end = last_input_start + (int)MathRound(60 * m_DPIScale);
    int last_big_input_start = first_column_start + (int)MathRound(250 * m_DPIScale);

    int panel_end = third_column_start + narrow_label_width;
    int panel_farther_end = panel_end + (int)MathRound(70 * m_DPIScale);

// Start
    int y = row_start;
    if (!LabelCreate(m_LblStatus, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblStatus", "Status:"))                                          return false;

// Tab Buttons
    y += element_height + v_spacing;
    if (!ButtonCreate(m_BtnTabMain, first_column_start, y, first_column_start + tab_button_width, y + element_height, "m_BtnTabMain", "Main")) return false;
    if (!ButtonCreate(m_BtnTabFilters, first_column_start + tab_button_width + tab_button_spacing, y, first_column_start + tab_button_width * 2 + tab_button_spacing, y + element_height, "m_BtnTabFilters", "Filters")) return false;
    if (!ButtonCreate(m_BtnTabConditions, first_column_start + tab_button_width * 2 + tab_button_spacing * 2, y, first_column_start + tab_button_width * 3 + tab_button_spacing * 2, y + element_height, "m_BtnTabConditions", "Conditions")) return false;
    if (!ButtonCreate(m_BtnTabActions, first_column_start + tab_button_width * 3 + tab_button_spacing * 3, y, first_column_start + tab_button_width * 4 + tab_button_spacing * 3, y + element_height, "m_BtnTabActions", "Actions")) return false;

// Main Tab Objects
    y += element_height + 3 * v_spacing;
    if (!LabelCreate(m_LblSpread, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblSpread", "Spread: " + DoubleToString((double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * SymbolInfoDouble(Symbol(), SYMBOL_POINT), (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS))))                                        return false;
    if (!CheckBoxCreate(m_ChkCountCommSwaps, second_column_main_start, y, panel_farther_end, y + element_height, "m_ChkCountCommSwaps", "Count commission/swaps"))            return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkUseTimer, first_column_start, y, second_column_magic_start, y + element_height, "m_ChkUseTimer", "Use timer:"))          return false;
    if (!EditCreate(m_EdtTimer, second_column_magic_start, y, second_column_magic_start + timer_width, y + element_height, "m_EdtTimer", "00:00"))                                                                return false;
    string m_RgpTimeType_Text[2] = {"Server time", "Local time"};
    if (!RadioGroupCreate(m_RgpTimeType, second_column_main_start, y, second_column_main_start + timer_radio_width, y + element_height * 2, "m_RgpTimeType", m_RgpTimeType_Text))             return false;
    if (!LabelCreate(m_LblTimeLeft, timer_label_start, y, timer_label_start + timer_width, y + element_height, "m_LblTimeLeft", "Time left:"))                                        return false;
    y += element_height + v_spacing;
    if (!LabelCreate(m_LblDayOfWeek, first_column_start, y, first_column_start + timer_width, y + element_height, "m_LblDayOfWeek", "Day: "))                                         return false;
    if (!ButtonCreate(m_BtnDayOfWeek, first_column_start + timer_width, y, second_column_magic_start + timer_width, y + element_height, "m_BtnDayOfWeek", "Any")) return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkTrailingStart, first_column_start, y, panel_end, y + element_height, "m_ChkTrailingStart", "Profit value (points) to start trailing SL:"))             return false;
    if (!EditCreate(m_EdtTrailingStart, last_input_start, y, last_input_end, y + element_height, "m_EdtTrailingStart", "0"))                                                              return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkTrailingStep, first_column_start, y, panel_end, y + element_height, "m_ChkTrailingStep", "Trailing SL value (points):"))           return false;
    if (!EditCreate(m_EdtTrailingStep, last_input_start, y, last_input_end, y + element_height, "m_EdtTrailingStep", "0"))                                                                return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkBreakEven, first_column_start, y, panel_end, y + element_height, "m_ChkBreakEven", "Profit value (points) to set SL to breakeven:"))          return false;
    if (!EditCreate(m_EdtBreakEven, last_input_start, y, last_input_end, y + element_height, "m_EdtBreakEven", "0"))                                                              return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkBreakEvenExtra, first_column_start, y, panel_end, y + element_height, "m_ChkBreakEvenExtra", "Breakeven extra profit value (points):"))            return false;
    if (!EditCreate(m_EdtBreakEvenExtra, last_input_start, y, last_input_end, y + element_height, "m_EdtBreakEvenExtra", "0"))                                                                return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkEquityTrailingStop, first_column_start, y, panel_end, y + element_height, "m_ChkEquityTrailingStop", "Equity trailing stop (hidden), USD:"))             return false;
    if (!EditCreate(m_EdtEquityTrailingStop, last_input_start, y, last_input_end, y + element_height, "m_EdtEquityTrailingStop", "0"))                                                                return false;
    y += element_height + v_spacing;
    if (!LabelCreate(m_LblCurrentEquityStopLoss, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblCurrentEquityStopLoss", "Current equity stop-loss, USD: "))                                        return false;
    if (!ButtonCreate(m_BtnResetEquityStopLoss, last_input_start, y, last_input_end, y + element_height, "m_BtnResetEquityStopLoss", "Reset SL")) return false;
    y += element_height + v_spacing;
    if (!LabelCreate(m_LblSnapEquity, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblSnapEquity", "Snapshot of equity: "))                                         return false;
    y += element_height + v_spacing;
    if (!LabelCreate(m_LblSnapMargin, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblSnapMargin", "Snapshot of free margin: "))                                        return false;
    y += element_height + v_spacing;
    if (!ButtonCreate(m_BtnNewSnapEquity, first_column_start, y, first_column_start + snap_button_width, y + element_height, "m_BtnNewSnapEquity", "New snapshot of equity")) return false;
    if (!ButtonCreate(m_BtnNewSnapMargin, first_column_start + snap_button_width + h_spacing, y, panel_farther_end, y + element_height, "m_BtnNewSnapMargin", "New snapshot of free margin")) return false;
    if (EnableEmergencyButton == Yes)
    {
        y += element_height + 3 * v_spacing;
        if (!ButtonCreate(m_BtnEmergency, first_column_start, y, panel_farther_end, y + (int)(element_height * 2.5), "m_BtnEmergency", "Emergency button")) return false;
        m_BtnEmergency.ColorBackground(clrRed);
        m_BtnEmergency.Color(clrWhite);
        y += (int)(element_height * 2.5) + v_spacing;
    }
    else y += element_height + v_spacing;

    if (!LabelCreate(m_LblURL, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblURL", "www.earnforex.com"))                                          return false;
    if (!m_LblURL.FontSize(8)) return false;
    if (!m_LblURL.Color(C'0,115,66')) return false; // Green
    m_LblURL.Show();

// Filters Tab Objects
    y = row_start + 2 * element_height + 4 * v_spacing;
    if (!LabelCreate(m_LblMagics, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblMagics", "Magic numbers:"))                                       return false;
    if (!EditCreate(m_EdtMagics, second_column_magic_start, y, second_column_magic_end, y + element_height, "m_EdtMagics", ""))                                                               return false;
    if (!CheckBoxCreate(m_ChkExcludeMagics, third_column_magic_start, y, panel_farther_end, y + element_height, "m_ChkExcludeMagics", "Exclude"))             return false;
    y += element_height + v_spacing;
    string m_RgpInstrumentFilter_Text[5] = {"Do not filter by trading instrument", "Use only with current trading instrument", "Exclude current trading instrument", "Include listed trading instruments only", "Exclude listed trading instruments"};
    if (!RadioGroupCreate(m_RgpInstrumentFilter, first_column_start, y, second_column_magic_end, y + element_height * 5, "m_RgpInstrumentFilter", m_RgpInstrumentFilter_Text))            return false;
    y += element_height * 5 + v_spacing;
    if (!LabelCreate(m_LblInstruments, first_column_start, y, panel_farther_end, y + element_height, "m_LblInstruments", "List of included/excluded trading instruments:"))                                       return false;
    y += element_height + v_spacing;
    if (!EditCreate(m_EdtInstruments, first_column_start, y, panel_farther_end, y + element_height, "m_EdtInstruments", ""))                                                               return false;
    y += element_height + v_spacing;
    if (!LabelCreate(m_LblOrderCommentary, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_LblOrderCommentary", "Order commentary"))                                       return false;
    string m_CbxOrderCommentaryCondition_Text[4] = {"contains", "equals", "excludes", "not equal"};
    if (!ComboBoxCreate(m_CbxOrderCommentaryCondition, second_column_start, y, second_column_start + narrow_edit_width, y + element_height, "m_CbxOrderCommentaryCondition", m_CbxOrderCommentaryCondition_Text))                                         return false;
    if (!EditCreate(m_EdtOrderCommentary, order_commentary_start, y, panel_farther_end, y + element_height, "m_EdtOrderCommentary", ""))                                                              return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkIgnoreLossTrades, first_column_start, y, second_column_start + narrow_edit_width, y + element_height, "m_ChkIgnoreLossTrades", "Ignore losing trades"))             return false;
    if (!CheckBoxCreate(m_ChkIgnoreProfitTrades, order_commentary_start, y, panel_farther_end, y + element_height, "m_ChkIgnoreProfitTrades", "Ignore profitable trades"))             return false;
    y += element_height + v_spacing;
    if (!ButtonCreate(m_BtnResetFilters, first_column_start, y, first_column_start + normal_label_width, y + element_height, "m_BtnResetFilters", "Reset filters")) return false;

// Conditions Tab Objects
    y = row_start + 2 * element_height + 2 * v_spacing;
    if (!DisableFloatLossRisePerc)
    {
        if (!CheckBoxCreate(m_ChkLossPerBalance, first_column_start, y, panel_end, y + element_height, "m_ChkLossPerBalance", "Floating loss rises to % of balance:"))            return false;
        if (!EditCreate(m_EdtLossPerBalance, last_input_start, y, last_input_end, y + element_height, "m_EdtLossPerBalance", "0"))            return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatLossFallPerc)
    {
        if (!CheckBoxCreate(m_ChkLossPerBalanceReverse, first_column_start, y, panel_end, y + element_height, "m_ChkLossPerBalanceReverse", "Floating loss falls to % of balance:"))          return false;
        if (!EditCreate(m_EdtLossPerBalanceReverse, last_input_start, y, last_input_end, y + element_height, "m_EdtLossPerBalanceReverse", "0"))          return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatLossRiseCurr)
    {
        if (!CheckBoxCreate(m_ChkLossQuanUnits, first_column_start, y, panel_end, y + element_height, "m_ChkLossQuanUnits", "Floating loss rises to currency units:"))            return false;
        if (!EditCreate(m_EdtLossQuanUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtLossQuanUnits", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatLossFallCurr)
    {
        if (!CheckBoxCreate(m_ChkLossQuanUnitsReverse, first_column_start, y, panel_end, y + element_height, "m_ChkLossQuanUnitsReverse", "Floating loss falls to currency units:"))          return false;
        if (!EditCreate(m_EdtLossQuanUnitsReverse, last_big_input_start, y, last_input_end, y + element_height, "m_EdtLossQuanUnitsReverse", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatLossRisePoints)
    {
        if (!CheckBoxCreate(m_ChkLossPoints, first_column_start, y, panel_end, y + element_height, "m_ChkLossPoints", "Floating loss rises to points:"))            return false;
        if (!EditCreate(m_EdtLossPoints, last_input_start, y, last_input_end, y + element_height, "m_EdtLossPoints", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatLossFallPoints)
    {
        if (!CheckBoxCreate(m_ChkLossPointsReverse, first_column_start, y, panel_end, y + element_height, "m_ChkLossPointsReverse", "Floating loss falls to points:"))          return false;
        if (!EditCreate(m_EdtLossPointsReverse, last_input_start, y, last_input_end, y + element_height, "m_EdtLossPointsReverse", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitRisePerc)
    {
        if (!CheckBoxCreate(m_ChkProfPerBalance, first_column_start, y, panel_end, y + element_height, "m_ChkProfPerBalance", "Floating profit rises % of balance:"))             return false;
        if (!EditCreate(m_EdtProfPerBalance, last_input_start, y, last_input_end, y + element_height, "m_EdtProfPerBalance", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitFallPerc)
    {
        if (!CheckBoxCreate(m_ChkProfPerBalanceReverse, first_column_start, y, panel_end, y + element_height, "m_ChkProfPerBalanceReverse", "Floating profit falls % of balance:"))           return false;
        if (!EditCreate(m_EdtProfPerBalanceReverse, last_input_start, y, last_input_end, y + element_height, "m_EdtProfPerBalanceReverse", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitRiseCurr)
    {
        if (!CheckBoxCreate(m_ChkProfQuanUnits, first_column_start, y, panel_end, y + element_height, "m_ChkProfQuanUnits", "Floating profit rises to currency units:"))          return false;
        if (!EditCreate(m_EdtProfQuanUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtProfQuanUnits", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitFallCurr)
    {
        if (!CheckBoxCreate(m_ChkProfQuanUnitsReverse, first_column_start, y, panel_end, y + element_height, "m_ChkProfQuanUnitsReverse", "Floating profit falls to currency units:"))            return false;
        if (!EditCreate(m_EdtProfQuanUnitsReverse, last_big_input_start, y, last_input_end, y + element_height, "m_EdtProfQuanUnitsReverse", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitRisePoints)
    {
        if (!CheckBoxCreate(m_ChkProfPoints, first_column_start, y, panel_end, y + element_height, "m_ChkProfPoints", "Floating profit rises to points:"))          return false;
        if (!EditCreate(m_EdtProfPoints, last_input_start, y, last_input_end, y + element_height, "m_EdtProfPoints", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableFloatProfitFallPoints)
    {
        if (!CheckBoxCreate(m_ChkProfPointsReverse, first_column_start, y, panel_end, y + element_height, "m_ChkProfPointsReverse", "Floating profit falls to points:"))            return false;
        if (!EditCreate(m_EdtProfPointsReverse, last_input_start, y, last_input_end, y + element_height, "m_EdtProfPointsReverse", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!CheckBoxCreate(m_ChkEquityLessUnits, first_column_start, y, panel_end, y + element_height, "m_ChkEquityLessUnits", "Equity <= currency units:"))             return false;
    if (!EditCreate(m_EdtEquityLessUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtEquityLessUnits", "0"))   return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkEquityGrUnits, first_column_start, y, panel_end, y + element_height, "m_ChkEquityGrUnits", "Equity >= currency units:"))             return false;
    if (!EditCreate(m_EdtEquityGrUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtEquityGrUnits", "0"))   return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkEquityLessPerSnap, first_column_start, y, panel_end, y + element_height, "m_ChkEquityLessPerSnap", "Equity <= % of snapshot:"))          return false;
    if (!EditCreate(m_EdtEquityLessPerSnap, last_input_start, y, last_input_end, y + element_height, "m_EdtEquityLessPerSnap", "0"))  return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkEquityGrPerSnap, first_column_start, y, panel_end, y + element_height, "m_ChkEquityGrPerSnap", "Equity >= % of snapshot:"))          return false;
    if (!EditCreate(m_EdtEquityGrPerSnap, last_input_start, y, last_input_end, y + element_height, "m_EdtEquityGrPerSnap", "0")) return false;
    y += element_height + v_spacing;
    if (!DisableEquityMinusSnapshot)
    {
        if (!CheckBoxCreate(m_ChkEquityMinusSnapshot, first_column_start, y, panel_end, y + element_height, "m_ChkEquityMinusSnapshot", "Equity - snapshot >= currency units:"))          return false;
        if (!EditCreate(m_EdtEquityMinusSnapshot, last_big_input_start, y, last_input_end, y + element_height, "m_EdtEquityMinusSnapshot", "0")) return false;
        y += element_height + v_spacing;
    }
    if (!DisableSnapshotMinusEquity)
    {
        if (!CheckBoxCreate(m_ChkSnapshotMinusEquity, first_column_start, y, panel_end, y + element_height, "m_ChkSnapshotMinusEquity", "Snapshot - Equity >= currency units:"))          return false;
        if (!EditCreate(m_EdtSnapshotMinusEquity, last_big_input_start, y, last_input_end, y + element_height, "m_EdtSnapshotMinusEquity", "0")) return false;
        y += element_height + v_spacing;
    }
    if (!CheckBoxCreate(m_ChkMarginLessUnits, first_column_start, y, panel_end, y + element_height, "m_ChkMarginLessUnits", "Free margin <= currency units:"))            return false;
    if (!EditCreate(m_EdtMarginLessUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtMarginLessUnits", "0"))   return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkMarginGrUnits, first_column_start, y, panel_end, y + element_height, "m_ChkMarginGrUnits", "Free margin >= currency units:"))            return false;
    if (!EditCreate(m_EdtMarginGrUnits, last_big_input_start, y, last_input_end, y + element_height, "m_EdtMarginGrUnits", "0"))   return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkMarginLessPerSnap, first_column_start, y, panel_end, y + element_height, "m_ChkMarginLessPerSnap", "Free margin <= % of snapshot:"))             return false;
    if (!EditCreate(m_EdtMarginLessPerSnap, last_input_start, y, last_input_end, y + element_height, "m_EdtMarginLessPerSnap", "0"))  return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkMarginGrPerSnap, first_column_start, y, panel_end, y + element_height, "m_ChkMarginGrPerSnap", "Free margin >= % of snapshot:"))             return false;
    if (!EditCreate(m_EdtMarginGrPerSnap, last_input_start, y, last_input_end, y + element_height, "m_EdtMarginGrPerSnap", "0"))   return false;

    if (!DisableCurrentPriceGE)
    {
        if (!CheckBoxCreate(m_ChkPriceGE, first_column_start, y, panel_end, y + element_height, "m_ChkPriceGE", "Current price >="))            return false;
        if (!EditCreate(m_EdtPriceGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtPriceGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableCurrentPriceLE)
    {
        if (!CheckBoxCreate(m_ChkPriceLE, first_column_start, y, panel_end, y + element_height, "m_ChkPriceLE", "Current price <="))            return false;
        if (!EditCreate(m_EdtPriceLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtPriceLE", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!DisableMarginLevelGE)
    {
        if (!CheckBoxCreate(m_ChkMarginLevelGE, first_column_start, y, panel_end, y + element_height, "m_ChkMarginLevelGE", "Margin level >= %"))            return false;
        if (!EditCreate(m_EdtMarginLevelGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtMarginLevelGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableMarginLevelLE)
    {
        if (!CheckBoxCreate(m_ChkMarginLevelLE, first_column_start, y, panel_end, y + element_height, "m_ChkMarginLevelLE", "Margin level <= %"))            return false;
        if (!EditCreate(m_EdtMarginLevelLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtMarginLevelLE", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!DisableSpreadGE)
    {
        if (!CheckBoxCreate(m_ChkSpreadGE, first_column_start, y, panel_end, y + element_height, "m_ChkSpreadGE", "Spread >= points"))            return false;
        if (!EditCreate(m_EdtSpreadGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtSpreadGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableSpreadLE)
    {
        if (!CheckBoxCreate(m_ChkSpreadLE, first_column_start, y, panel_end, y + element_height, "m_ChkSpreadLE", "Spread <= points"))            return false;
        if (!EditCreate(m_EdtSpreadLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtSpreadLE", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!DisableDailyProfitLossUnitsGE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossUnitsGE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossUnitsGE", "Daily profit/loss >= currency units"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossUnitsGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossUnitsGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableDailyProfitLossUnitsLE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossUnitsLE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossUnitsLE", "Daily profit/loss <= currency units"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossUnitsLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossUnitsLE", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!DisableDailyProfitLossPointsGE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossPointsGE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossPointsGE", "Daily profit/loss >= points"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossPointsGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossPointsGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableDailyProfitLossPointsLE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossPointsLE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossPointsLE", "Daily profit/loss <= points"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossPointsLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossPointsLE", "0"))   return false;
        y += element_height + v_spacing;
    }

    if (!DisableDailyProfitLossPercGE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossPercGE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossPercGE", "Daily profit/loss >= %"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossPercGE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossPercGE", "0"))   return false;
        y += element_height + v_spacing;
    }
    if (!DisableDailyProfitLossPercLE)
    {
        if (!CheckBoxCreate(m_ChkDailyProfitLossPercLE, first_column_start, y, panel_end, y + element_height, "m_ChkDailyProfitLossPercLE", "Daily profit/loss <= %"))            return false;
        if (!EditCreate(m_EdtDailyProfitLossPercLE, last_big_input_start, y, last_input_end, y + element_height, "m_EdtDailyProfitLossPercLE", "0"))   return false;
        y += element_height + v_spacing;
    }

// Actions Tab Objects
    y = row_start + 2 * element_height + 4 * v_spacing;
    if (!CheckBoxCreate(m_ChkClosePos, first_column_start, y, first_column_start + narrowest_edit_width, y + element_height, "m_ChkClosePos", "Close "))          return false;
    if (!EditCreate(m_EdtClosePercentage, first_column_start + narrowest_edit_width + v_spacing, y, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width, y + element_height, "m_EdtClosePercentage", "100"))             return false;
    if (!LabelCreate(m_LblClosePosSuffix, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width + v_spacing, y, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width + shortest_edit_width, y + element_height, "m_LblClosePosSuffix", "% of "))                                       return false;
    if (!ButtonCreate(m_BtnPositionStatus, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width + shortest_edit_width, y, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width + shortest_edit_width + narrow_edit_width, y + element_height, "m_BtnPositionStatus", "All")) return false;
    if (!LabelCreate(m_LblClosePosPostfix, first_column_start + narrowest_edit_width + v_spacing + narrowest_edit_width + shortest_edit_width + narrow_edit_width, y, panel_end, y + element_height, "m_LblClosePosPostfix", " positions' volume."))                                          return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkDeletePend, first_column_start, y, panel_end, y + element_height, "m_ChkDeletePend", "Delete all pending orders"))           return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkDisAuto, first_column_start, y, panel_end, y + element_height, "m_ChkDisAuto", "Disable autotrading"))           return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkSendMails, first_column_start, y, panel_end, y + element_height, "m_ChkSendMails", "Send e-mail"))           return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkSendNotif, first_column_start, y, panel_end, y + element_height, "m_ChkSendNotif", "Send push notification"))            return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkClosePlatform, first_column_start, y, panel_end, y + element_height, "m_ChkClosePlatform", "Close platform"))            return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkEnableAuto, first_column_start, y, panel_end, y + element_height, "m_ChkEnableAuto", "Enable autotrading"))          return false;
    y += element_height + v_spacing;
    if (!CheckBoxCreate(m_ChkRecaptureSnapshots, first_column_start, y, panel_end, y + element_height, "m_ChkRecaptureSnapshots", "Recapture snapshots"))             return false;

    InitObjects();

    return true;
}

// Initializes all panel objects after they are created.
bool CAccountProtector::InitObjects()
{
    //+-------------------------------------+
    //| Align text from objects all objects |
    //+-------------------------------------+
    ENUM_ALIGN_MODE align = ALIGN_RIGHT;
    if (!m_EdtTimer.TextAlign(align)) return false;
    if (!DisableFloatLossRisePerc) if (!m_EdtLossPerBalance.TextAlign(align)) return false;
    if (!DisableFloatLossFallPerc) if (!m_EdtLossPerBalanceReverse.TextAlign(align)) return false;
    if (!DisableFloatLossRiseCurr) if (!m_EdtLossQuanUnits.TextAlign(align)) return false;
    if (!DisableFloatLossFallCurr) if (!m_EdtLossQuanUnitsReverse.TextAlign(align)) return false;
    if (!DisableFloatLossRisePoints) if (!m_EdtLossPoints.TextAlign(align)) return false;
    if (!DisableFloatLossFallPoints) if (!m_EdtLossPointsReverse.TextAlign(align)) return false;
    if (!DisableFloatProfitRisePerc) if (!m_EdtProfPerBalance.TextAlign(align)) return false;
    if (!DisableFloatProfitFallPerc) if (!m_EdtProfPerBalanceReverse.TextAlign(align)) return false;
    if (!DisableFloatProfitRiseCurr) if (!m_EdtProfQuanUnits.TextAlign(align)) return false;
    if (!DisableFloatProfitFallCurr) if (!m_EdtProfQuanUnitsReverse.TextAlign(align)) return false;
    if (!DisableFloatProfitRisePoints) if (!m_EdtProfPoints.TextAlign(align)) return false;
    if (!DisableFloatProfitFallPoints) if (!m_EdtProfPointsReverse.TextAlign(align)) return false;
    if (!m_EdtEquityLessUnits.TextAlign(align)) return false;
    if (!m_EdtEquityGrUnits.TextAlign(align)) return false;
    if (!m_EdtEquityLessPerSnap.TextAlign(align)) return false;
    if (!m_EdtEquityGrPerSnap.TextAlign(align)) return false;
    if (!DisableEquityMinusSnapshot) if (!m_EdtEquityMinusSnapshot.TextAlign(align)) return false;
    if (!DisableSnapshotMinusEquity) if (!m_EdtSnapshotMinusEquity.TextAlign(align)) return false;
    if (!m_EdtMarginLessUnits.TextAlign(align)) return false;
    if (!m_EdtMarginLessPerSnap.TextAlign(align)) return false;
    if (!m_EdtMarginGrUnits.TextAlign(align)) return false;
    if (!m_EdtMarginGrPerSnap.TextAlign(align)) return false;
    if (!DisableCurrentPriceGE) if (!m_EdtPriceGE.TextAlign(align)) return false;
    if (!DisableCurrentPriceLE) if (!m_EdtPriceLE.TextAlign(align)) return false;
    if (!DisableMarginLevelGE) if (!m_EdtMarginLevelGE.TextAlign(align)) return false;
    if (!DisableMarginLevelLE) if (!m_EdtMarginLevelLE.TextAlign(align)) return false;
    if (!DisableSpreadGE) if (!m_EdtSpreadGE.TextAlign(align)) return false;
    if (!DisableSpreadLE) if (!m_EdtSpreadLE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossUnitsGE) if (!m_EdtDailyProfitLossUnitsGE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossUnitsLE) if (!m_EdtDailyProfitLossUnitsLE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossPointsGE) if (!m_EdtDailyProfitLossPointsGE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossPointsLE) if (!m_EdtDailyProfitLossPointsLE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossPercGE) if (!m_EdtDailyProfitLossPercGE.TextAlign(align)) return false;
    if (!DisableDailyProfitLossPercLE) if (!m_EdtDailyProfitLossPercLE.TextAlign(align)) return false;
    if (!m_EdtTrailingStart.TextAlign(align)) return false;
    if (!m_EdtTrailingStep.TextAlign(align)) return false;
    if (!m_EdtBreakEven.TextAlign(align)) return false;
    if (!m_EdtBreakEvenExtra.TextAlign(align)) return false;
    if (!m_EdtEquityTrailingStop.TextAlign(align)) return false;
    if (!m_EdtClosePercentage.TextAlign(align)) return false;

    ShowSelectedTab();

    // Show/hide current equity stop-loss
    if (sets.doubleCurrentEquityStopLoss != 0)
    {
        if (!m_LblCurrentEquityStopLoss.Hide())                           return false;
        if (!m_BtnResetEquityStopLoss.Hide())                             return false;
    }

    SeekAndDestroyDuplicatePanels();

    return true;
}

void CAccountProtector::ShowSelectedTab()
{
    HideMain();
    HideFilters();
    HideConditions();
    HideActions();

    if (!m_minimized)
    {
        if (sets.SelectedTab == MainTab) ShowMain();
        else if (sets.SelectedTab == FiltersTab) ShowFilters();
        else if (sets.SelectedTab == ConditionsTab) ShowConditions();
        else if (sets.SelectedTab == ActionsTab) ShowActions();
    }

    MoveAndResize();
}

// Adjusts panel's height accordingly to the chosen TabButton.
void CAccountProtector::MoveAndResize()
{
    int col_height = (int)MathRound(24 * m_DPIScale);
    int new_height = col_height;
    int ref_point = 0;

    if (sets.SelectedTab == MainTab)
    {
        ref_point = m_ChkEquityTrailingStop.Top();
        if (sets.doubleCurrentEquityStopLoss != 0)
        {
            m_LblCurrentEquityStopLoss.Move(m_LblCurrentEquityStopLoss.Left(), ref_point + 1 * col_height);
            m_BtnResetEquityStopLoss.Move(m_BtnResetEquityStopLoss.Left(), ref_point + 1 * col_height);
            m_LblCurrentEquityStopLoss.Show();
            m_BtnResetEquityStopLoss.Show();
            ref_point = ref_point + 1 * col_height;
        }
        else
        {
            m_LblCurrentEquityStopLoss.Hide();
            m_BtnResetEquityStopLoss.Hide();
        }
        m_LblSnapEquity.Move(m_LblSnapEquity.Left(), ref_point + 1 * col_height);
        m_LblSnapMargin.Move(m_LblSnapMargin.Left(), ref_point + 2 * col_height);
        m_BtnNewSnapEquity.Move(m_BtnNewSnapEquity.Left(), ref_point + 3 * col_height);
        m_BtnNewSnapMargin.Move(m_BtnNewSnapMargin.Left(), ref_point + 3 * col_height);
        if (EnableEmergencyButton == Yes)
        {
            m_BtnEmergency.Move(m_BtnEmergency.Left(), ref_point + 4 * col_height);
            ref_point = m_BtnEmergency.Top() + (int)MathRound(30 * m_DPIScale);
        }
        else
        {
            ref_point = m_BtnNewSnapMargin.Top();
        }
    }
    else if (sets.SelectedTab == FiltersTab)
    {
        // Move stuff below the radiogroup based on the radigroup option.
        // The last two options add two lines between the radiogroup and the "Order commentary" fields - they and everything below has to be moved.
        if ((sets.intInstrumentFilter == 3) || (sets.intInstrumentFilter == 4))
        {
            m_LblInstruments.Show();
            m_EdtInstruments.Show();
            ref_point = m_EdtInstruments.Top();
            m_LblOrderCommentary.Move(m_LblOrderCommentary.Left(), ref_point + col_height * 1);
            m_CbxOrderCommentaryCondition.Move(m_CbxOrderCommentaryCondition.Left(), ref_point + col_height * 1);
            m_EdtOrderCommentary.Move(m_EdtOrderCommentary.Left(), ref_point + col_height * 1);
            m_ChkIgnoreLossTrades.Move(m_ChkIgnoreLossTrades.Left(), ref_point + col_height * 2);
            m_ChkIgnoreProfitTrades.Move(m_ChkIgnoreProfitTrades.Left(), ref_point + col_height * 2);
            m_BtnResetFilters.Move(m_BtnResetFilters.Left(), ref_point + col_height * 3);
            m_LblURL.Move(m_LblURL.Left(), ref_point + col_height * 4);
        }
        else
        {
            ref_point = m_RgpInstrumentFilter.Top();
            m_LblInstruments.Hide();
            m_EdtInstruments.Hide();
            m_LblOrderCommentary.Move(m_LblOrderCommentary.Left(), ref_point + (int)MathRound(col_height * 4.5));
            m_CbxOrderCommentaryCondition.Move(m_CbxOrderCommentaryCondition.Left(), ref_point + (int)MathRound(col_height * 4.5));
            m_EdtOrderCommentary.Move(m_EdtOrderCommentary.Left(), ref_point + (int)MathRound(col_height * 4.5));
            m_ChkIgnoreLossTrades.Move(m_ChkIgnoreLossTrades.Left(), ref_point + (int)MathRound(col_height * 5.5));
            m_ChkIgnoreProfitTrades.Move(m_ChkIgnoreProfitTrades.Left(), ref_point + (int)MathRound(col_height * 5.5));
            m_BtnResetFilters.Move(m_BtnResetFilters.Left(), ref_point + (int)MathRound(col_height * 6.5));
            m_LblURL.Move(m_LblURL.Left(), ref_point + (int)MathRound(col_height * 7.5));
        }
        
        ref_point = m_BtnResetFilters.Top();
    }
    else if (sets.SelectedTab == ConditionsTab)
    {
        if (!DisableDailyProfitLossPercLE) ref_point = m_EdtDailyProfitLossPercLE.Top();
        else if (!DisableDailyProfitLossPercGE) ref_point = m_EdtDailyProfitLossPercGE.Top();
        else if (!DisableDailyProfitLossPointsLE) ref_point = m_EdtDailyProfitLossPointsLE.Top();
        else if (!DisableDailyProfitLossPointsGE) ref_point = m_EdtDailyProfitLossPointsGE.Top();
        else if (!DisableDailyProfitLossUnitsLE) ref_point = m_EdtDailyProfitLossUnitsLE.Top();
        else if (!DisableDailyProfitLossUnitsGE) ref_point = m_EdtDailyProfitLossUnitsGE.Top();
        else if (!DisableSpreadLE) ref_point = m_EdtSpreadLE.Top();
        else if (!DisableSpreadGE) ref_point = m_EdtSpreadGE.Top();
        else if (!DisableMarginLevelLE) ref_point = m_EdtMarginLevelLE.Top();
        else if (!DisableMarginLevelGE) ref_point = m_EdtMarginLevelGE.Top();
        else if (!DisableCurrentPriceLE) ref_point = m_EdtPriceLE.Top();
        else if (!DisableCurrentPriceGE) ref_point = m_EdtPriceGE.Top();
        else ref_point = m_EdtMarginGrPerSnap.Top();
    }
    else if (sets.SelectedTab == ActionsTab)
    {
        ref_point = m_ChkRecaptureSnapshots.Top();
    }

    m_LblURL.Move(m_LblURL.Left(), ref_point + col_height);
    new_height = m_LblURL.Top() + col_height - Top();

    if (!m_minimized)
    {
        // Resize window.
        Height(new_height);
        // Needed only in case of initialization when actual panel maximization is avoided.
        if (NoPanelMaximization) Width((int)MathRound(390 * m_DPIScale));
    }
    NoPanelMaximization = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::Minimize()
{
    CAppDialog::Minimize();
    if (remember_left != -1) Move(remember_left, remember_top);
}

// Processes click on the panel's Maximize button of the panel.
void CAccountProtector::Maximize()
{
    if (!NoPanelMaximization) CAppDialog::Maximize();
    else if (m_minimized) CAppDialog::Minimize();

    ShowSelectedTab();

    if (remember_left != -1) Move(remember_left, remember_top);
}

// Refreshes Status, Spread-value, and TimeLeft-value.
bool CAccountProtector::RefreshValues()
{
    Check_Status();
    if (!m_LblSpread.Text("Spread: " + DoubleToString((double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * SymbolInfoDouble(Symbol(), SYMBOL_POINT), (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)))) return false;
    if (m_ChkUseTimer.Checked())
    {
        sets.TimeLeft = NewTime();
        m_LblTimeLeft.Text("Time left: " + sets.TimeLeft);
    }
    else m_LblTimeLeft.Text("Time left: ---");
    string account_currency = AccountCurrency();
    if (account_currency != "") m_ChkEquityTrailingStop.Text("Equity trailing stop (hidden), " + account_currency + ":");

    if (IsANeedToContinueClosingOrders) Close_All_Positions();
    if (IsANeedToContinueDeletingPendingOrders) Delete_All_Pending_Orders();

    return true;
}

// Updates all panel controls depending on the settings in sets struct.
void CAccountProtector::RefreshPanelControls()
{
    // Main tab

    // Refresh "Count commission/swaps".
    m_ChkCountCommSwaps.Checked(sets.CountCommSwaps);

    // Refresh timer fields.
    if (sets.UseTimer)
    {
        m_ChkUseTimer.Checked(true);
    }
    else
    {
        m_ChkUseTimer.Checked(false);
        m_LblTimeLeft.Text("Time left: ---");
    }
    m_EdtTimer.Text(sets.Timer);
    m_BtnDayOfWeek.Text(EnumToString(sets.TimerDayOfWeek));

    // Refresh time type radio group.
    m_RgpTimeType.Value(sets.intTimeType);

    // Refresh trailing stop start fields.
    RefreshConditions(sets.boolTrailingStart, sets.intTrailingStart, m_ChkTrailingStart, m_EdtTrailingStart, 0);

    // Refresh trailing stop step fields.
    RefreshConditions(sets.boolTrailingStep, sets.intTrailingStep, m_ChkTrailingStep, m_EdtTrailingStep, 0);

    // Refresh breakeven fields.
    RefreshConditions(sets.boolBreakEven, sets.intBreakEven, m_ChkBreakEven, m_EdtBreakEven, 0);

    // Refresh breakeven extra fields.
    RefreshConditions(sets.boolBreakEvenExtra, sets.intBreakEvenExtra, m_ChkBreakEvenExtra, m_EdtBreakEvenExtra, 0);

    // Refresh equity trailing stop fields.
    RefreshConditions(sets.boolEquityTrailingStop, sets.doubleEquityTrailingStop, m_ChkEquityTrailingStop, m_EdtEquityTrailingStop, 2);

    string AdditionalFunds_Asterisk = "";
    if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";
    
    // Refresh snapshot of equity.
    if (sets.SnapEquityTime != "") m_LblSnapEquity.Text("Snapshot of equity: " + DoubleToString(sets.SnapEquity, 2) + " (" + sets.SnapEquityTime + ")" + AdditionalFunds_Asterisk);
    else m_LblSnapEquity.Text("Snapshot of equity: ");

    // Refresh snapshot of margin.
    if (sets.SnapMarginTime != "") m_LblSnapMargin.Text("Snapshot of free margin: " + DoubleToString(sets.SnapMargin, 2) + " (" + sets.SnapMarginTime + ")" + AdditionalFunds_Asterisk);
    else m_LblSnapMargin.Text("Snapshot of free margin: ");

    // Filters tab

    // Refresh order commentary condition list view.
    m_CbxOrderCommentaryCondition.Select(sets.intOrderCommentaryCondition);
    // Refresh order commentary edit.
    m_EdtOrderCommentary.Text(sets.OrderCommentary);

    // Refresh magic numbers.
    m_EdtMagics.Text(sets.MagicNumbers);
    ProcessMagicNumbers();
    // Refresh "Exclude" checkbox for magic numbers.
    m_ChkExcludeMagics.Checked(sets.boolExcludeMagics);

    // Refresh trading instrument radio group.
    m_RgpInstrumentFilter.Value(sets.intInstrumentFilter);
    // Refresh trading instrument list.
    m_EdtInstruments.Text(sets.Instruments);
    ProcessInstruments();

    // Refresh "Ignore" checkboxes.
    m_ChkIgnoreLossTrades.Checked(sets.boolIgnoreLossTrades);
    m_ChkIgnoreProfitTrades.Checked(sets.boolIgnoreProfitTrades);

    // Conditions tab

    // Refresh "Floating loss rises to % of balance" fields.
    if (!DisableFloatLossRisePerc) RefreshConditions(sets.boolLossPerBalance, sets.doubleLossPerBalance, m_ChkLossPerBalance, m_EdtLossPerBalance);

    // Refresh "Floating loss falls to % of balance" fields.
    if (!DisableFloatLossFallPerc) RefreshConditions(sets.boolLossPerBalanceReverse, sets.doubleLossPerBalanceReverse, m_ChkLossPerBalanceReverse, m_EdtLossPerBalanceReverse);

    // Refresh "Floating loss rises to currency units" fields.
    if (!DisableFloatLossRiseCurr) RefreshConditions(sets.boolLossQuanUnits, sets.doubleLossQuanUnits, m_ChkLossQuanUnits, m_EdtLossQuanUnits);

    // Refresh "Floating loss falls to currency units" fields.
    if (!DisableFloatLossFallCurr) RefreshConditions(sets.boolLossQuanUnitsReverse, sets.doubleLossQuanUnitsReverse, m_ChkLossQuanUnitsReverse, m_EdtLossQuanUnitsReverse);

    // Refresh "Floating loss rises to points" fields.
    if (!DisableFloatLossRisePoints) RefreshConditions(sets.boolLossPoints, sets.intLossPoints, m_ChkLossPoints, m_EdtLossPoints, 0);

    // Refresh "Floating loss falls to points" fields.
    if (!DisableFloatLossFallPoints) RefreshConditions(sets.boolLossPointsReverse, sets.intLossPointsReverse, m_ChkLossPointsReverse, m_EdtLossPointsReverse, 0);

    // Refresh "Floating profit rises to % of balance" fields.
    if (!DisableFloatProfitRisePerc) RefreshConditions(sets.boolProfPerBalance, sets.doubleProfPerBalance, m_ChkProfPerBalance, m_EdtProfPerBalance);

    // Refresh "Floating profit falls to % of balance" fields.
    if (!DisableFloatProfitFallPerc) RefreshConditions(sets.boolProfPerBalanceReverse, sets.doubleProfPerBalanceReverse, m_ChkProfPerBalanceReverse, m_EdtProfPerBalanceReverse);

    // Refresh "Floating profit rises to currency units" fields.
    if (!DisableFloatProfitRiseCurr) RefreshConditions(sets.boolProfQuanUnits, sets.doubleProfQuanUnits, m_ChkProfQuanUnits, m_EdtProfQuanUnits);

    // Refresh "Floating profit falls to currency units" fields.
    if (!DisableFloatProfitFallCurr) RefreshConditions(sets.boolProfQuanUnitsReverse, sets.doubleProfQuanUnitsReverse, m_ChkProfQuanUnitsReverse, m_EdtProfQuanUnitsReverse);

    // Refresh "Floating profit rises to points" fields.
    if (!DisableFloatProfitRisePoints) RefreshConditions(sets.boolProfPoints, sets.intProfPoints, m_ChkProfPoints, m_EdtProfPoints, 0);

    // Refresh "Floating profit falls to points" fields.
    if (!DisableFloatProfitFallPoints) RefreshConditions(sets.boolProfPointsReverse, sets.intProfPointsReverse, m_ChkProfPointsReverse, m_EdtProfPointsReverse, 0);

    // Refresh "Equity <= currency units" fields.
    RefreshConditions(sets.boolEquityLessUnits, sets.doubleEquityLessUnits, m_ChkEquityLessUnits, m_EdtEquityLessUnits);

    // Refresh "Equity >= currency units" fields.
    RefreshConditions(sets.boolEquityGrUnits, sets.doubleEquityGrUnits, m_ChkEquityGrUnits, m_EdtEquityGrUnits);

    // Refresh "Equity <= % of snapshot" fields.
    RefreshConditions(sets.boolEquityLessPerSnap, sets.doubleEquityLessPerSnap, m_ChkEquityLessPerSnap, m_EdtEquityLessPerSnap);
    if (sets.SnapEquityTime != "") m_ChkEquityLessPerSnap.Text("Equity <= % of snapshot (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + ":");
    else m_ChkEquityLessPerSnap.Text("Equity <= % of snapshot:");

    // Refresh "Equity >= % of snapshot" fields.
    RefreshConditions(sets.boolEquityGrPerSnap, sets.doubleEquityGrPerSnap, m_ChkEquityGrPerSnap, m_EdtEquityGrPerSnap);
    if (sets.SnapEquityTime != "") m_ChkEquityGrPerSnap.Text("Equity >= % of snapshot (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + ":");
    else m_ChkEquityGrPerSnap.Text("Equity >= % of snapshot:");

    // Refresh "Equity - Snapshot >= currency units" fields.
    if (!DisableEquityMinusSnapshot)
    {
        RefreshConditions(sets.boolEquityMinusSnapshot, sets.doubleEquityMinusSnapshot, m_ChkEquityMinusSnapshot, m_EdtEquityMinusSnapshot);
        if (sets.SnapEquityTime != "") m_ChkEquityMinusSnapshot.Text("Equity - snapshot (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + " >=");
        else m_ChkEquityMinusSnapshot.Text("Equity - snapshot >= currency units:");
    }

    // Refresh "Snapshot - Equity >= currency units" fields.
    if (!DisableSnapshotMinusEquity)
    {
        RefreshConditions(sets.boolSnapshotMinusEquity, sets.doubleSnapshotMinusEquity, m_ChkSnapshotMinusEquity, m_EdtSnapshotMinusEquity);
        if (sets.SnapEquityTime != "") m_ChkSnapshotMinusEquity.Text("Snapshot - Equity (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + " >=");
        else m_ChkSnapshotMinusEquity.Text("Snapshot - Equity >= currency units:");
    }

    // Refresh "Free margin <= currency units" fields.
    RefreshConditions(sets.boolMarginLessUnits, sets.doubleMarginLessUnits, m_ChkMarginLessUnits, m_EdtMarginLessUnits);

    // Refresh "Free margin >= currency units" fields.
    RefreshConditions(sets.boolMarginGrUnits, sets.doubleMarginGrUnits, m_ChkMarginGrUnits, m_EdtMarginGrUnits);

    // Refresh "Free margin <= % of snapshot" fields.
    RefreshConditions(sets.boolMarginLessPerSnap, sets.doubleMarginLessPerSnap, m_ChkMarginLessPerSnap, m_EdtMarginLessPerSnap);
    if (sets.SnapMarginTime != "") m_ChkMarginLessPerSnap.Text("Free margin <= % of snapshot (" + DoubleToString(sets.SnapMargin, 2) + ")" + AdditionalFunds_Asterisk + ":");
    else m_ChkMarginLessPerSnap.Text("Free margin <= % of snapshot:");

    // Refresh "Free margin >= % of snapshot" fields.
    RefreshConditions(sets.boolMarginGrPerSnap, sets.doubleMarginGrPerSnap, m_ChkMarginGrPerSnap, m_EdtMarginGrPerSnap);
    if (sets.SnapMarginTime != "") m_ChkMarginGrPerSnap.Text("Free margin >= % of snapshot (" + DoubleToString(sets.SnapMargin, 2) + ")" + AdditionalFunds_Asterisk + ":");
    else m_ChkMarginGrPerSnap.Text("Free margin >= % of snapshot:");

    // Refresh "Current price greater or equal" fields.
    if (!DisableCurrentPriceGE) RefreshConditions(sets.boolPriceGE, sets.doublePriceGE, m_ChkPriceGE, m_EdtPriceGE, _Digits);

    // Refresh "Current price less or equal" fields.
    if (!DisableCurrentPriceLE) RefreshConditions(sets.boolPriceLE, sets.doublePriceLE, m_ChkPriceLE, m_EdtPriceLE, _Digits);

    // Refresh "Margin level greater or equal" fields.
    if (!DisableMarginLevelGE) RefreshConditions(sets.boolMarginLevelGE, sets.doubleMarginLevelGE, m_ChkMarginLevelGE, m_EdtMarginLevelGE, 2);

    // Refresh "Margin level less or equal" fields.
    if (!DisableMarginLevelLE) RefreshConditions(sets.boolMarginLevelLE, sets.doubleMarginLevelLE, m_ChkMarginLevelLE, m_EdtMarginLevelLE, 2);

    // Refresh "Spread greater or equal" fields.
    if (!DisableSpreadGE) RefreshConditions(sets.boolSpreadGE, sets.intSpreadGE, m_ChkSpreadGE, m_EdtSpreadGE, 0);

    // Refresh "Spread less or equal" fields.
    if (!DisableSpreadLE) RefreshConditions(sets.boolSpreadLE, sets.intSpreadLE, m_ChkSpreadLE, m_EdtSpreadLE, 0);

    // Refresh "Daily profit/loss greater or equal currency units" fields.
    if (!DisableDailyProfitLossUnitsGE) RefreshConditions(sets.boolDailyProfitLossUnitsGE, sets.doubleDailyProfitLossUnitsGE, m_ChkDailyProfitLossUnitsGE, m_EdtDailyProfitLossUnitsGE);

    // Refresh "Daily profit/loss less or equal currency units" fields.
    if (!DisableDailyProfitLossUnitsLE) RefreshConditions(sets.boolDailyProfitLossUnitsLE, sets.doubleDailyProfitLossUnitsLE, m_ChkDailyProfitLossUnitsLE, m_EdtDailyProfitLossUnitsLE);

    // Refresh "Daily profit/loss greater or equal points" fields.
    if (!DisableDailyProfitLossPointsGE) RefreshConditions(sets.boolDailyProfitLossPointsGE, sets.intDailyProfitLossPointsGE, m_ChkDailyProfitLossPointsGE, m_EdtDailyProfitLossPointsGE, 0);

    // Refresh "Daily profit/loss less or equal points" fields.
    if (!DisableDailyProfitLossPointsLE) RefreshConditions(sets.boolDailyProfitLossPointsLE, sets.intDailyProfitLossPointsLE, m_ChkDailyProfitLossPointsLE, m_EdtDailyProfitLossPointsLE, 0);

    // Refresh "Daily profit/loss greater or equal percentage" fields.
    if (!DisableDailyProfitLossPercGE) RefreshConditions(sets.boolDailyProfitLossPercGE, sets.doubleDailyProfitLossPercGE, m_ChkDailyProfitLossPercGE, m_EdtDailyProfitLossPercGE, 2);

    // Refresh "Daily profit/loss less or equal percentage" fields.
    if (!DisableDailyProfitLossPercLE) RefreshConditions(sets.boolDailyProfitLossPercLE, sets.doubleDailyProfitLossPercLE, m_ChkDailyProfitLossPercLE, m_EdtDailyProfitLossPercLE, 2);

    // Actions tab

    // Refresh "Close all positions" checkbox.
    m_ChkClosePos.Checked(sets.ClosePos);
    // Refresh "Close Percentage" field. Not a condition, but works with the same funciton.
    RefreshConditions(sets.ClosePos, sets.doubleClosePercentage, m_ChkClosePos, m_EdtClosePercentage, 2);
    // Refresh button status (All, Losing, or Profitable).
    m_BtnPositionStatus.Text(EnumToString(sets.CloseWhichPositions));

    // Refresh "Delete all pending orders" checkbox.
    m_ChkDeletePend.Checked(sets.DeletePend);

    // Refresh "Disable AutoTrading" checkbox.
    m_ChkDisAuto.Checked(sets.DisAuto);

    // Refresh "Send e-mail" checkbox.
    m_ChkSendMails.Checked(sets.SendMails);

    // Refresh "Send push notification" checkbox.
    m_ChkSendNotif.Checked(sets.SendNotif);

    // Refresh "Close platform" checkbox.
    m_ChkClosePlatform.Checked(sets.ClosePlatform);

    // Refresh "Enable AutoTrading" checkbox.
    m_ChkEnableAuto.Checked(sets.EnableAuto);

    // Refresh "Recapture snapshots" checkbox.
    m_ChkRecaptureSnapshots.Checked(sets.RecaptureSnapshots);

    // Refresh status label.
    if (sets.Triggered) m_LblStatus.Text("Status: Triggered at " + sets.TriggeredTime);
}

// Hides design-elements of TabButton "Main".
void CAccountProtector::HideMain()
{
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_LblSpread.Hide();
    m_ChkCountCommSwaps.Hide();
    m_ChkUseTimer.Hide();
    m_EdtTimer.Hide();
    m_RgpTimeType.Hide();
    m_LblTimeLeft.Hide();
    m_LblDayOfWeek.Hide();
    m_BtnDayOfWeek.Hide();
    m_ChkTrailingStart.Hide();
    m_ChkTrailingStep.Hide();
    m_ChkBreakEven.Hide();
    m_ChkBreakEvenExtra.Hide();
    m_ChkEquityTrailingStop.Hide();
    m_EdtTrailingStart.Hide();
    m_EdtTrailingStep.Hide();
    m_EdtBreakEven.Hide();
    m_EdtBreakEvenExtra.Hide();
    m_EdtEquityTrailingStop.Hide();
    m_LblSnapEquity.Hide();
    m_LblSnapMargin.Hide();
    m_LblCurrentEquityStopLoss.Hide();
    m_BtnNewSnapEquity.Hide();
    m_BtnNewSnapMargin.Hide();
    m_BtnEmergency.Hide();
    m_BtnResetEquityStopLoss.Hide();
}

// Shows design-elements of TabButton "Main".
void CAccountProtector::ShowMain()
{
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_LblSpread.Show();
    m_ChkCountCommSwaps.Show();
    m_ChkUseTimer.Show();
    m_EdtTimer.Show();
    m_RgpTimeType.Show();
    m_LblTimeLeft.Show();
    m_LblDayOfWeek.Show();
    m_BtnDayOfWeek.Show();
    m_ChkTrailingStart.Show();
    m_ChkTrailingStep.Show();
    m_ChkBreakEven.Show();
    m_ChkBreakEvenExtra.Show();
    m_ChkEquityTrailingStop.Show();
    m_EdtTrailingStart.Show();
    m_EdtTrailingStep.Show();
    m_EdtBreakEven.Show();
    m_EdtBreakEvenExtra.Show();
    m_EdtEquityTrailingStop.Show();
    m_LblSnapEquity.Show();
    m_LblSnapMargin.Show();
    m_LblCurrentEquityStopLoss.Show();
    m_BtnNewSnapEquity.Show();
    m_BtnNewSnapMargin.Show();
    m_BtnEmergency.Show();
    m_BtnResetEquityStopLoss.Show();
}

// Hides design-elements of TabButton "Filters".
void CAccountProtector::HideFilters()
{
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_LblOrderCommentary.Hide();
    m_CbxOrderCommentaryCondition.Hide();
    m_EdtOrderCommentary.Hide();
    m_LblMagics.Hide();
    m_EdtMagics.Hide();
    m_ChkExcludeMagics.Hide();
    m_RgpInstrumentFilter.Hide();
    m_LblInstruments.Hide();
    m_EdtInstruments.Hide();
    m_ChkIgnoreLossTrades.Hide();
    m_ChkIgnoreProfitTrades.Hide();
    m_BtnResetFilters.Hide();
}

// Shows design-elements of TabButton "Filters".
void CAccountProtector::ShowFilters()
{
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_LblOrderCommentary.Show();
    m_CbxOrderCommentaryCondition.Show();
    m_EdtOrderCommentary.Show();
    m_LblMagics.Show();
    m_EdtMagics.Show();
    m_ChkExcludeMagics.Show();
    m_RgpInstrumentFilter.Show();
    if ((sets.intInstrumentFilter == 3) || (sets.intInstrumentFilter == 4))
    {
        m_LblInstruments.Show();
        m_EdtInstruments.Show();
    }
    m_ChkIgnoreLossTrades.Show();
    m_ChkIgnoreProfitTrades.Show();
    m_BtnResetFilters.Show();
}

// Hides design-elements of TabButton "Conditions".
void CAccountProtector::HideConditions()
{
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_ChkLossPerBalance.Hide();
    m_ChkLossPerBalanceReverse.Hide();
    m_ChkLossQuanUnits.Hide();
    m_ChkLossQuanUnitsReverse.Hide();
    m_ChkLossPoints.Hide();
    m_ChkLossPointsReverse.Hide();
    m_ChkProfPerBalance.Hide();
    m_ChkProfPerBalanceReverse.Hide();
    m_ChkProfQuanUnits.Hide();
    m_ChkProfQuanUnitsReverse.Hide();
    m_ChkProfPoints.Hide();
    m_ChkProfPointsReverse.Hide();
    m_ChkEquityLessUnits.Hide();
    m_ChkEquityLessPerSnap.Hide();
    m_ChkEquityGrUnits.Hide();
    m_ChkEquityGrPerSnap.Hide();
    m_ChkEquityMinusSnapshot.Hide();
    m_ChkSnapshotMinusEquity.Hide();
    m_ChkMarginLessUnits.Hide();
    m_ChkMarginLessPerSnap.Hide();
    m_ChkMarginGrUnits.Hide();
    m_ChkMarginGrPerSnap.Hide();
    m_ChkPriceGE.Hide();
    m_ChkPriceLE.Hide();
    m_ChkMarginLevelGE.Hide();
    m_ChkMarginLevelLE.Hide();
    m_ChkDailyProfitLossUnitsGE.Hide();
    m_ChkDailyProfitLossUnitsLE.Hide();
    m_ChkDailyProfitLossPointsGE.Hide();
    m_ChkDailyProfitLossPointsLE.Hide();
    m_ChkDailyProfitLossPercGE.Hide();
    m_ChkDailyProfitLossPercLE.Hide();
    m_ChkSpreadGE.Hide();
    m_ChkSpreadLE.Hide();
    m_EdtLossPerBalance.Hide();
    m_EdtLossPerBalanceReverse.Hide();
    m_EdtLossQuanUnits.Hide();
    m_EdtLossQuanUnitsReverse.Hide();
    m_EdtLossPoints.Hide();
    m_EdtLossPointsReverse.Hide();
    m_EdtProfPerBalance.Hide();
    m_EdtProfPerBalanceReverse.Hide();
    m_EdtProfQuanUnits.Hide();
    m_EdtProfQuanUnitsReverse.Hide();
    m_EdtProfPoints.Hide();
    m_EdtProfPointsReverse.Hide();
    m_EdtEquityLessUnits.Hide();
    m_EdtEquityLessPerSnap.Hide();
    m_EdtEquityGrUnits.Hide();
    m_EdtEquityGrPerSnap.Hide();
    m_EdtEquityMinusSnapshot.Hide();
    m_EdtSnapshotMinusEquity.Hide();
    m_EdtMarginLessUnits.Hide();
    m_EdtMarginLessPerSnap.Hide();
    m_EdtMarginGrUnits.Hide();
    m_EdtMarginGrPerSnap.Hide();
    m_EdtPriceGE.Hide();
    m_EdtPriceLE.Hide();
    m_EdtMarginLevelGE.Hide();
    m_EdtMarginLevelLE.Hide();
    m_EdtDailyProfitLossUnitsGE.Hide();
    m_EdtDailyProfitLossUnitsLE.Hide();
    m_EdtDailyProfitLossPointsGE.Hide();
    m_EdtDailyProfitLossPointsLE.Hide();
    m_EdtDailyProfitLossPercGE.Hide();
    m_EdtDailyProfitLossPercLE.Hide();
    m_EdtSpreadGE.Hide();
    m_EdtSpreadLE.Hide();
}

// Shows design-elements of TabButton "Conditions".
void CAccountProtector::ShowConditions()
{
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_ChkLossPerBalance.Show();
    m_ChkLossPerBalanceReverse.Show();
    m_ChkLossQuanUnits.Show();
    m_ChkLossQuanUnitsReverse.Show();
    m_ChkLossPoints.Show();
    m_ChkLossPointsReverse.Show();
    m_ChkProfPerBalance.Show();
    m_ChkProfPerBalanceReverse.Show();
    m_ChkProfQuanUnits.Show();
    m_ChkProfQuanUnitsReverse.Show();
    m_ChkProfPoints.Show();
    m_ChkProfPointsReverse.Show();
    m_ChkEquityLessUnits.Show();
    m_ChkEquityLessPerSnap.Show();
    m_ChkEquityGrUnits.Show();
    m_ChkEquityGrPerSnap.Show();
    m_ChkEquityMinusSnapshot.Show();
    m_ChkSnapshotMinusEquity.Show();
    m_ChkMarginLessUnits.Show();
    m_ChkMarginLessPerSnap.Show();
    m_ChkMarginGrUnits.Show();
    m_ChkMarginGrPerSnap.Show();
    m_ChkPriceGE.Show();
    m_ChkPriceLE.Show();
    m_ChkMarginLevelGE.Show();
    m_ChkMarginLevelLE.Show();
    m_ChkSpreadGE.Show();
    m_ChkSpreadLE.Show();
    m_ChkDailyProfitLossUnitsGE.Show();
    m_ChkDailyProfitLossUnitsLE.Show();
    m_ChkDailyProfitLossPointsGE.Show();
    m_ChkDailyProfitLossPointsLE.Show();
    m_ChkDailyProfitLossPercGE.Show();
    m_ChkDailyProfitLossPercLE.Show();
    m_EdtLossPerBalance.Show();
    m_EdtLossPerBalanceReverse.Show();
    m_EdtLossQuanUnits.Show();
    m_EdtLossQuanUnitsReverse.Show();
    m_EdtLossPoints.Show();
    m_EdtLossPointsReverse.Show();
    m_EdtProfPerBalance.Show();
    m_EdtProfPerBalanceReverse.Show();
    m_EdtProfQuanUnits.Show();
    m_EdtProfQuanUnitsReverse.Show();
    m_EdtProfPoints.Show();
    m_EdtProfPointsReverse.Show();
    m_EdtEquityLessUnits.Show();
    m_EdtEquityLessPerSnap.Show();
    m_EdtEquityGrUnits.Show();
    m_EdtEquityGrPerSnap.Show();
    m_EdtEquityMinusSnapshot.Show();
    m_EdtSnapshotMinusEquity.Show();
    m_EdtMarginLessUnits.Show();
    m_EdtMarginLessPerSnap.Show();
    m_EdtMarginGrUnits.Show();
    m_EdtMarginGrPerSnap.Show();
    m_EdtPriceGE.Show();
    m_EdtPriceLE.Show();
    m_EdtMarginLevelGE.Show();
    m_EdtMarginLevelLE.Show();
    m_EdtSpreadGE.Show();
    m_EdtSpreadLE.Show();
    m_EdtDailyProfitLossUnitsGE.Show();
    m_EdtDailyProfitLossUnitsLE.Show();
    m_EdtDailyProfitLossPointsGE.Show();
    m_EdtDailyProfitLossPointsLE.Show();
    m_EdtDailyProfitLossPercGE.Show();
    m_EdtDailyProfitLossPercLE.Show();
}

// Hides design-elements of TabButton "Actions".
void CAccountProtector::HideActions()
{
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_ChkClosePos.Hide();
    m_EdtClosePercentage.Hide();
    m_LblClosePosSuffix.Hide();
    m_BtnPositionStatus.Hide();
    m_LblClosePosPostfix.Hide();
    m_ChkDeletePend.Hide();
    m_ChkDisAuto.Hide();
    m_ChkSendMails.Hide();
    m_ChkSendNotif.Hide();
    m_ChkClosePlatform.Hide();
    m_ChkEnableAuto.Hide();
    m_ChkRecaptureSnapshots.Hide();
}

// Shows design-elements of TabButton "Actions".
void CAccountProtector::ShowActions()
{
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_ChkClosePos.Show();
    m_EdtClosePercentage.Show();
    m_LblClosePosSuffix.Show();
    m_BtnPositionStatus.Show();
    m_LblClosePosPostfix.Show();
    m_ChkDeletePend.Show();
    m_ChkDisAuto.Show();
    m_ChkSendMails.Show();
    m_ChkSendNotif.Show();
    m_ChkClosePlatform.Show();
    m_ChkEnableAuto.Show();
    m_ChkRecaptureSnapshots.Show();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::SeekAndDestroyDuplicatePanels()
{
    int ot = ObjectsTotal(ChartID());
    for (int i = ot - 1; i >= 0; i--)
    {
        string object_name = ObjectName(ChartID(), i);
        if (ObjectGetInteger(ChartID(), object_name, OBJPROP_TYPE) != OBJ_LABEL) continue;
        // Found m_LblSnapEquity object.
        if (StringSubstr(object_name, StringLen(object_name) - 15) == "m_LblSnapEquity")
        {
            string prefix = StringSubstr(object_name, 0, StringLen(Name()));
            // Found m_LblSnapEquity object with prefix different than current.
            if (prefix != Name())
            {
                ObjectsDeleteAll(ChartID(), prefix);
                // Reset object counter.
                ot = ObjectsTotal(ChartID());
                i = ot;
                Print("Deleted duplicate panel objects with prefix = ", prefix, ".");
                continue;
            }
        }
    }
}

//+--------------------------------------------+
//|                                            |
//|                   EVENTS                   |
//|                                            |
//+--------------------------------------------+

// Click on the Main tab.
void CAccountProtector::OnClickBtnTabMain()
{
    if (sets.SelectedTab == MainTab) return;
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    sets.SelectedTab = MainTab;
    ShowMain();
    HideConditions();
    HideFilters();
    HideActions();
    MoveAndResize();
}

// Click on the Filters tab.
void CAccountProtector::OnClickBtnTabFilters()
{
    if (sets.SelectedTab == FiltersTab) return;
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    sets.SelectedTab = FiltersTab;
    ShowFilters();
    HideMain();
    HideConditions();
    HideActions();
    MoveAndResize();
}

// Click on the Conditions tab.
void CAccountProtector::OnClickBtnTabConditions()
{
    if (sets.SelectedTab == ConditionsTab) return;
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    sets.SelectedTab = ConditionsTab;
    ShowConditions();
    HideMain();
    HideFilters();
    HideActions();
    MoveAndResize();
}

// Click on the Actions tab.
void CAccountProtector::OnClickBtnTabActions()
{
    if (sets.SelectedTab == ActionsTab) return;
    m_BtnTabMain.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabFilters.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabConditions.ColorBackground(CONTROLS_BUTTON_COLOR_DISABLE);
    m_BtnTabActions.ColorBackground(CONTROLS_BUTTON_COLOR_ENABLE);
    sets.SelectedTab = ActionsTab;
    HideConditions();
    HideMain();
    HideFilters();
    ShowActions();
    MoveAndResize();
}

// Changes Checkbox "Count Commission/Swaps".
void CAccountProtector::OnChangeChkCountCommSwaps()
{
    if (sets.CountCommSwaps != m_ChkCountCommSwaps.Checked())
    {
        sets.CountCommSwaps = m_ChkCountCommSwaps.Checked();
        SaveSettingsOnDisk();
    }
}

// Changes Checkbox "Use Timer".
void CAccountProtector::OnChangeChkUseTimer()
{
    if (sets.UseTimer != m_ChkUseTimer.Checked())
    {
        sets.UseTimer = m_ChkUseTimer.Checked();
        if (!m_ChkUseTimer.Checked()) m_LblTimeLeft.Text("Time left: ---");
        sets.Triggered = false;
        sets.TriggeredTime = "";
        SaveSettingsOnDisk();
    }
}

// Edit input field of Timer.
void CAccountProtector::OnEndEditTimer()
{
    string time = m_EdtTimer.Text();

    if (StringLen(time) == 4) time = "0" + time;

    if (
        // Wrong length.
        (StringLen(time) != 5) ||
        // Wrong separator.
        (time[2] != ':') ||
        // Wrong first number (only 24 hours in a day).
        ((time[0] < '0') || (time[0] > '2')) ||
        // 00 to 09 and 10 to 19.
        (((time[0] == '0') || (time[0] == '1')) && ((time[1] < '0') || (time[1] > '9'))) ||
        // 20 to 23.
        ((time[0] == '2') && ((time[1] < '0') || (time[1] > '3'))) ||
        // 0M to 5M.
        ((time[3] < '0') || (time[3] > '5')) ||
        // M0 to M9.
        ((time[4] < '0') || (time[4] > '9'))
    )
    {
        Logging(LOG_TIMER_VALUE_WRONG);
        LoadSettingsFromDisk();
        return;
    }

    if (sets.Timer != time)
    {
        sets.Timer = time;
        RefreshValues();
        sets.Triggered = false;
        sets.TriggeredTime = "";
        SaveSettingsOnDisk();
    }
}

// Saves input from the time type radio group.
void CAccountProtector::OnChangeRgpTimeType()
{
    if (sets.intTimeType != m_RgpTimeType.Value())
    {
        sets.intTimeType = (int)m_RgpTimeType.Value();
        SaveSettingsOnDisk();
    }
}

// Supplementary function to process checkbox clicks (for Main tab).
void CAccountProtector::CheckboxChangeMain(bool& SettingsCheckboxValue, CCheckBox& CheckBox)
{
    if (SettingsCheckboxValue != CheckBox.Checked())
    {
        SettingsCheckboxValue = CheckBox.Checked();
        SaveSettingsOnDisk();
    }
}

// Changes Checkbox "Profit value (points) to start Trailing SL".
void CAccountProtector::OnChangeChkTrailingStart()
{
    CheckboxChangeMain(sets.boolTrailingStart, m_ChkTrailingStart);
}

// Changes Checkbox "Trailing SL value (points)".
void CAccountProtector::OnChangeChkTrailingStep()
{
    CheckboxChangeMain(sets.boolTrailingStep, m_ChkTrailingStep);
}

// Changes Checkbox "Profit value (points) to move SL to Breakeven".
void CAccountProtector::OnChangeChkBreakEven()
{
    CheckboxChangeMain(sets.boolBreakEven, m_ChkBreakEven);
}

// Changes Checkbox "Breakeven extra profit value (points)".
void CAccountProtector::OnChangeChkBreakEvenExtra()
{
    CheckboxChangeMain(sets.boolBreakEvenExtra, m_ChkBreakEvenExtra);
}

// Changes Checkbox "Equity trailing stop (hidden)".
void CAccountProtector::OnChangeChkEquityTrailingStop()
{
    CheckboxChangeMain(sets.boolEquityTrailingStop, m_ChkEquityTrailingStop);

// Reset and hide in any case because: unchecking turns equity SL off; checking just turns on, so everything starts anew.
    sets.doubleCurrentEquityStopLoss = 0;
    m_LblCurrentEquityStopLoss.Hide();
    m_BtnResetEquityStopLoss.Hide();

    MoveAndResize();
}

// Processes click on the "Reset equity stop-loss" button.
void CAccountProtector::OnClickBtnResetEquityStopLoss()
{
// Reset and hide in any case because everything starts anew - no need to show 0 equity stop-loss.
    sets.doubleCurrentEquityStopLoss = 0;
    SaveSettingsOnDisk();

    m_LblCurrentEquityStopLoss.Hide();
    m_BtnResetEquityStopLoss.Hide();

    MoveAndResize();
}

// Processes click on the "New Snapshot of Equity" button.
void CAccountProtector::OnClickBtnNewSnapEquity()
{
    UpdateEquitySnapshot();
    SaveSettingsOnDisk();
}

// Actual equity snapshot update - can be called from different places.
void CAccountProtector::UpdateEquitySnapshot()
{
    string AdditionalFunds_Asterisk = "";
    sets.SnapEquity = AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds;
    if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";
    sets.SnapEquityTime = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    m_LblSnapEquity.Text("Snapshot of Equity: " + DoubleToString(sets.SnapEquity, 2) + " (" + sets.SnapEquityTime + ")" + AdditionalFunds_Asterisk);
    m_ChkEquityLessPerSnap.Text("Equity <= % of Snapshot: (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk);
    m_ChkEquityGrPerSnap.Text("Equity >= % of Snapshot: (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk);
    if (!DisableEquityMinusSnapshot) m_ChkEquityMinusSnapshot.Text("Equity - snapshot (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + " >=");
    if (!DisableSnapshotMinusEquity) m_ChkSnapshotMinusEquity.Text("Snapshot - Equity (" + DoubleToString(sets.SnapEquity, 2) + ")" + AdditionalFunds_Asterisk + " >=");
}

// Processes click on the "New Snapshot of Free Margin" button.
void CAccountProtector::OnClickBtnNewSnapMargin()
{
    UpdateMarginSnapshot();
    SaveSettingsOnDisk();
}

// Actual margin snapshot update - can be called from different places.
void CAccountProtector::UpdateMarginSnapshot()
{
    string AdditionalFunds_Asterisk = "";
    sets.SnapMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds;
    if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";
    sets.SnapMarginTime = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    m_LblSnapMargin.Text("Snapshot of Free Margin: " + DoubleToString(sets.SnapMargin, 2) + " (" + sets.SnapMarginTime + ")" + AdditionalFunds_Asterisk);
    m_ChkMarginLessPerSnap.Text("Free Margin <= % of Snapshot: (" + DoubleToString(sets.SnapMargin, 2) + ")" + AdditionalFunds_Asterisk);
    m_ChkMarginGrPerSnap.Text("Free Margin >= % of Snapshot: (" + DoubleToString(sets.SnapMargin, 2) + ")" + AdditionalFunds_Asterisk);
}

// Saves input from the order commentary condition list view.
void CAccountProtector::OnChangeCbxOrderCommentaryCondition()
{
    if (sets.intOrderCommentaryCondition != m_CbxOrderCommentaryCondition.Value())
    {
        sets.intOrderCommentaryCondition = (int)m_CbxOrderCommentaryCondition.Value();
        SaveSettingsOnDisk();
    }
}

// Processes edit of input-field of order commentary.
void CAccountProtector::OnEndEditOrderCommentary()
{
    string order_commentary = m_EdtOrderCommentary.Text();
    if (StringCompare(sets.OrderCommentary, order_commentary) != 0)
    {
        sets.OrderCommentary = order_commentary;
        SaveSettingsOnDisk();
    }
}

// Processes edit of input-field of Magic Numbers.
void CAccountProtector::OnEndEditMagics()
{
    string magic = m_EdtMagics.Text();
    int length = StringLen(magic);

// Only allowed characters are digits, commas, spaces, and semicolons. At least one digit should be present.

    for (int i = 0; i < length; i++)
    {
        if (((magic[i] < '0') || (magic[i] > '9')) && (magic[i] != ' ') && (magic[i] != ',') && (magic[i] != ';'))
        {
            // Wrong character found.
            int replaced_characters = StringReplace(magic, CharToString((uchar)magic[i]), "");
            length -= replaced_characters;
            i--;
        }
    }

    m_EdtMagics.Text(magic);

    if (StringCompare(sets.MagicNumbers, magic) != 0)
    {
        sets.MagicNumbers = magic;
        SaveSettingsOnDisk();
    }

    ProcessMagicNumbers();
}

// Saves input from Checkbox "Exclude" for magic numbers.
void CAccountProtector::OnChangeChkExcludeMagics()
{
    if (sets.boolExcludeMagics != m_ChkExcludeMagics.Checked())
    {
        sets.boolExcludeMagics = m_ChkExcludeMagics.Checked();
        SaveSettingsOnDisk();
    }
}

// Saves input from the trading instrument radio group.
void CAccountProtector::OnChangeRgpInstrumentFilter()
{
    if (sets.intInstrumentFilter != m_RgpInstrumentFilter.Value())
    {
        int prev_intInstrumentFilter = sets.intInstrumentFilter;
        sets.intInstrumentFilter = (int)m_RgpInstrumentFilter.Value();
        if (((sets.intInstrumentFilter < 3) && (prev_intInstrumentFilter >= 3)) || ((sets.intInstrumentFilter >= 3) && (prev_intInstrumentFilter < 3))) MoveAndResize();
        SaveSettingsOnDisk();
    }
}

// Processes edit of input field of Instruments.
void CAccountProtector::OnEndEditInstruments()
{
    string instruments = m_EdtInstruments.Text();

    if (StringCompare(sets.Instruments, instruments) != 0)
    {
        sets.Instruments = instruments;
        SaveSettingsOnDisk();
    }

    ProcessInstruments();
}

// Saves input from Checkbox "Ignore losing trades".
void CAccountProtector::OnChangeChkIgnoreLossTrades()
{
    if (sets.boolIgnoreLossTrades != m_ChkIgnoreLossTrades.Checked())
    {
        sets.boolIgnoreLossTrades = m_ChkIgnoreLossTrades.Checked();
        SaveSettingsOnDisk();
    }
}

// Saves input from Checkbox "Ignore profitable trades".
void CAccountProtector::OnChangeChkIgnoreProfitTrades()
{
    if (sets.boolIgnoreProfitTrades != m_ChkIgnoreProfitTrades.Checked())
    {
        sets.boolIgnoreProfitTrades = m_ChkIgnoreProfitTrades.Checked();
        SaveSettingsOnDisk();
    }
}

// Click on the "Reset filters" button.
void CAccountProtector::OnClickBtnResetFilters()
{
    bool need_to_save_to_disk = false;
    if (sets.intOrderCommentaryCondition != 0) need_to_save_to_disk = true;
    sets.intOrderCommentaryCondition = 0;
    m_CbxOrderCommentaryCondition.Select(0);
    if (StringCompare(sets.OrderCommentary, "") != 0) need_to_save_to_disk = true;
    sets.OrderCommentary = "";
    m_EdtOrderCommentary.Text("");
    if (StringCompare(sets.MagicNumbers, "") != 0) need_to_save_to_disk = true;
    sets.MagicNumbers = "";
    ProcessMagicNumbers();
    m_EdtMagics.Text("");
    if (sets.boolExcludeMagics != false) need_to_save_to_disk = true;
    sets.boolExcludeMagics = false;
    m_ChkExcludeMagics.Checked(false);
    if (sets.intInstrumentFilter != 0) need_to_save_to_disk = true;
    sets.intInstrumentFilter = 0;
    m_RgpInstrumentFilter.Value(0);
    if (StringCompare(sets.Instruments, "") != 0) need_to_save_to_disk = true;
    sets.Instruments = "";
    ProcessInstruments();
    m_EdtInstruments.Text("");
    if (sets.boolIgnoreLossTrades != false) need_to_save_to_disk = true;
    sets.boolIgnoreLossTrades = false;
    m_ChkIgnoreLossTrades.Checked(false);
    if (sets.boolIgnoreProfitTrades != false) need_to_save_to_disk = true;
    sets.boolIgnoreProfitTrades = false;
    m_ChkIgnoreProfitTrades.Checked(false);
    if (need_to_save_to_disk) SaveSettingsOnDisk();
}

// Supplementary function to process checkbox clicks (for Conditions tab).
void CAccountProtector::CheckboxChangeConditions(bool& SettingsCheckboxValue, CCheckBox& CheckBox)
{
    if (SettingsCheckboxValue != CheckBox.Checked())
    {
        SettingsCheckboxValue = CheckBox.Checked();
        sets.Triggered = false;
        sets.TriggeredTime = "";
        SaveSettingsOnDisk();
    }
}

// Changes Checkbox of Condition "Floating loss rises to % of balance".
void CAccountProtector::OnChangeChkLossPerBalance()
{
    CheckboxChangeConditions(sets.boolLossPerBalance, m_ChkLossPerBalance);
}

// Changes Checkbox of Condition "Floating loss falls to % of balance".
void CAccountProtector::OnChangeChkLossPerBalanceReverse()
{
    CheckboxChangeConditions(sets.boolLossPerBalanceReverse, m_ChkLossPerBalanceReverse);
}

// Changes Checkbox of Condition "Floating loss rises to currency units".
void CAccountProtector::OnChangeChkLossQuanUnits()
{
    CheckboxChangeConditions(sets.boolLossQuanUnits, m_ChkLossQuanUnits);
}

// Changes Checkbox of Condition "Floating loss falls to currency units".
void CAccountProtector::OnChangeChkLossQuanUnitsReverse()
{
    CheckboxChangeConditions(sets.boolLossQuanUnitsReverse, m_ChkLossQuanUnitsReverse);
}

// Changes Checkbox of Condition "Floating loss rises to points".
void CAccountProtector::OnChangeChkLossPoints()
{
    CheckboxChangeConditions(sets.boolLossPoints, m_ChkLossPoints);
}

// Changes Checkbox of Condition "Floating loss falls to points".
void CAccountProtector::OnChangeChkLossPointsReverse()
{
    CheckboxChangeConditions(sets.boolLossPointsReverse, m_ChkLossPointsReverse);
}

// Changes Checkbox of Condition "Floating profit rises to % of balance".
void CAccountProtector::OnChangeChkProfPerBalance()
{
    CheckboxChangeConditions(sets.boolProfPerBalance, m_ChkProfPerBalance);
}

// Changes Checkbox of Condition "Floating profit falls to % of balance".
void CAccountProtector::OnChangeChkProfPerBalanceReverse()
{
    CheckboxChangeConditions(sets.boolProfPerBalanceReverse, m_ChkProfPerBalanceReverse);
}

// Changes Checkbox of Condition "Floating profit rises to currency units".
void CAccountProtector::OnChangeChkProfQuanUnits()
{
    CheckboxChangeConditions(sets.boolProfQuanUnits, m_ChkProfQuanUnits);
}

// Changes Checkbox of Condition "Floating profit falls to currency units".
void CAccountProtector::OnChangeChkProfQuanUnitsReverse()
{
    CheckboxChangeConditions(sets.boolProfQuanUnitsReverse, m_ChkProfQuanUnitsReverse);
}

// Changes Checkbox of Condition "Floating profit rises to points".
void CAccountProtector::OnChangeChkProfPoints()
{
    CheckboxChangeConditions(sets.boolProfPoints, m_ChkProfPoints);
}

// Changes Checkbox of Condition "Floating profit falls to points".
void CAccountProtector::OnChangeChkProfPointsReverse()
{
    CheckboxChangeConditions(sets.boolProfPointsReverse, m_ChkProfPointsReverse);
}

// Changes Checkbox of Condition "Equity <= currency units".
void CAccountProtector::OnChangeChkEquityLessUnits()
{
    CheckboxChangeConditions(sets.boolEquityLessUnits, m_ChkEquityLessUnits);
}

// Changes Checkbox of Condition "Equity >= currency units".
void CAccountProtector::OnChangeChkEquityGrUnits()
{
    CheckboxChangeConditions(sets.boolEquityGrUnits, m_ChkEquityGrUnits);
}

// Changes Checkbox of Condition "Equity <= % of Snapshot".
void CAccountProtector::OnChangeChkEquityLessPerSnap()
{
    CheckboxChangeConditions(sets.boolEquityLessPerSnap, m_ChkEquityLessPerSnap);
}

// Changes Checkbox of Condition "Equity >= % of Snapshot".
void CAccountProtector::OnChangeChkEquityGrPerSnap()
{
    CheckboxChangeConditions(sets.boolEquityGrPerSnap, m_ChkEquityGrPerSnap);
}

// Changes Checkbox of Condition "Equity - Snapshot >= currency units".
void CAccountProtector::OnChangeChkEquityMinusSnapshot()
{
    CheckboxChangeConditions(sets.boolEquityMinusSnapshot, m_ChkEquityMinusSnapshot);
}

// Changes Checkbox of Condition "Snapshot - Equity >= currency units".
void CAccountProtector::OnChangeChkSnapshotMinusEquity()
{
    CheckboxChangeConditions(sets.boolSnapshotMinusEquity, m_ChkSnapshotMinusEquity);
}

// Changes Checkbox of Condition "Margin <= currency units".
void CAccountProtector::OnChangeChkMarginLessUnits()
{
    CheckboxChangeConditions(sets.boolMarginLessUnits, m_ChkMarginLessUnits);
}

// Changes Checkbox of Condition "Margin >= currency units".
void CAccountProtector::OnChangeChkMarginGrUnits()
{
    CheckboxChangeConditions(sets.boolMarginGrUnits, m_ChkMarginGrUnits);
}

// Changes Checkbox of Condition "Margin <= % of Snapshot".
void CAccountProtector::OnChangeChkMarginLessPerSnap()
{
    CheckboxChangeConditions(sets.boolMarginLessPerSnap, m_ChkMarginLessPerSnap);
}

// Changes Checkbox of Condition "Margin >= % of Snapshot".
void CAccountProtector::OnChangeChkMarginGrPerSnap()
{
    CheckboxChangeConditions(sets.boolMarginGrPerSnap, m_ChkMarginGrPerSnap);
}

// Changes Checkbox of Condition "Price >= value".
void CAccountProtector::OnChangeChkPriceGE()
{
    CheckboxChangeConditions(sets.boolPriceGE, m_ChkPriceGE);
}

// Changes Checkbox of Condition "Price <= value".
void CAccountProtector::OnChangeChkPriceLE()
{
    CheckboxChangeConditions(sets.boolPriceLE, m_ChkPriceLE);
}

// Changes Checkbox of Condition "Margin level >= % value".
void CAccountProtector::OnChangeChkMarginLevelGE()
{
    CheckboxChangeConditions(sets.boolMarginLevelGE, m_ChkMarginLevelGE);
}

// Changes Checkbox of Condition "Margin level <= % value".
void CAccountProtector::OnChangeChkMarginLevelLE()
{
    CheckboxChangeConditions(sets.boolMarginLevelLE, m_ChkMarginLevelLE);
}

// Changes Checkbox of Condition "Spread >= points".
void CAccountProtector::OnChangeChkSpreadGE()
{
    CheckboxChangeConditions(sets.boolSpreadGE, m_ChkSpreadGE);
}

// Changes Checkbox of Condition "Spread <= points".
void CAccountProtector::OnChangeChkSpreadLE()
{
    CheckboxChangeConditions(sets.boolSpreadLE, m_ChkSpreadLE);
}

// Changes Checkbox of Condition "Daily profit/loss >= units".
void CAccountProtector::OnChangeChkDailyProfitLossUnitsGE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossUnitsGE, m_ChkDailyProfitLossUnitsGE);
}

// Changes Checkbox of Condition "Daily profit/loss <= units".
void CAccountProtector::OnChangeChkDailyProfitLossUnitsLE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossUnitsLE, m_ChkDailyProfitLossUnitsLE);
}

// Changes Checkbox of Condition "Daily profit/loss >= points".
void CAccountProtector::OnChangeChkDailyProfitLossPointsGE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossPointsGE, m_ChkDailyProfitLossPointsGE);
}

// Changes Checkbox of Condition "Daily profit/loss <= points".
void CAccountProtector::OnChangeChkDailyProfitLossPointsLE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossPointsLE, m_ChkDailyProfitLossPointsLE);
}

// Changes Checkbox of Condition "Daily profit/loss >= %".
void CAccountProtector::OnChangeChkDailyProfitLossPercGE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossPercGE, m_ChkDailyProfitLossPercGE);
}

// Changes Checkbox of Condition "Daily profit/loss <= %".
void CAccountProtector::OnChangeChkDailyProfitLossPercLE()
{
    CheckboxChangeConditions(sets.boolDailyProfitLossPercLE, m_ChkDailyProfitLossPercLE);
}

// Supplementary function to process checkbox clicks (for Actions tab).
void CAccountProtector::CheckboxChangeActions(bool& SettingsCheckboxValue, CCheckBox& CheckBox)
{
    if (SettingsCheckboxValue != CheckBox.Checked())
    {
        SettingsCheckboxValue = CheckBox.Checked();
        sets.Triggered = false;
        sets.TriggeredTime = "";
        SaveSettingsOnDisk();
    }
}

// Changes Checkbox of Action "Close All Positions".
void CAccountProtector::OnChangeChkClosePos()
{
// Acts like a condition checkbox for close percentage edit.
    CheckboxChangeConditions(sets.ClosePos, m_ChkClosePos);
}

// Changes Checkbox of Action "Delete Pending Orders".
void CAccountProtector::OnChangeChkDeletePend()
{
    CheckboxChangeActions(sets.DeletePend, m_ChkDeletePend);
}

// Changes Checkbox of Action "Disable AutoTrading".
void CAccountProtector::OnChangeChkDisAuto()
{
    if (m_ChkEnableAuto.Checked())
    {
        m_ChkEnableAuto.Checked(false);
        sets.EnableAuto = false;
    }
    CheckboxChangeActions(sets.DisAuto, m_ChkDisAuto);
}

// Changes Checkbox of Action "Send Mails".
void CAccountProtector::OnChangeChkSendMails()
{
    CheckboxChangeActions(sets.SendMails, m_ChkSendMails);
}

// Changes Checkbox of Action "Send Notification".
void CAccountProtector::OnChangeChkSendNotif ()
{
    CheckboxChangeActions(sets.SendNotif, m_ChkSendNotif);
}

// Changes Checkbox of Action "Close Platform".
void CAccountProtector::OnChangeChkClosePlatform()
{
    CheckboxChangeActions(sets.ClosePlatform, m_ChkClosePlatform);
}

// Changes Checkbox of Action "Enable AutoTrading".
void CAccountProtector::OnChangeChkEnableAuto()
{
    if (m_ChkDisAuto.Checked())
    {
        m_ChkDisAuto.Checked(false);
        sets.DisAuto = false;
    }
    CheckboxChangeActions(sets.EnableAuto, m_ChkEnableAuto);
}

// Changes Checkbox of Action "Recapture snapshots".
void CAccountProtector::OnChangeChkRecaptureSnapshots()
{
    CheckboxChangeActions(sets.RecaptureSnapshots, m_ChkRecaptureSnapshots);
}

// Supplementary function to process changes to edit fields in the Conditions tab:
// 1. Check emptiness.
// 2. Check and log if double.
// 3. Check and log range validity.
// 4. Save if different from current.
template<typename T>
void CAccountProtector::EditChangeConditions(T& SettingsEditValue, CEdit& Edit, const string FieldName, const double RangeMaximum = 0)
{
    double ValueFromEdit = StringToDouble(Edit.Text());

    if (!IsDouble(Edit.Text()))
    {
        Logging("Value is wrong: " + FieldName + ".");
        LoadSettingsFromDisk();
    }
    else if ((RangeMaximum > 0) && (ValueFromEdit >= RangeMaximum))
    {
        Logging(FieldName + " value must be lower than " + DoubleToString(RangeMaximum, 2) + ".");
        LoadSettingsFromDisk();
    }
    else if (SettingsEditValue != ValueFromEdit)
    {
        SettingsEditValue = (T)ValueFromEdit;
        sets.Triggered = false;
        sets.TriggeredTime = "";
        SaveSettingsOnDisk();
    }
}

// Processes edit of input-field of Condition "Floating loss rises to % of balance".
void CAccountProtector::OnEndEditLossPerBalance()
{
    EditChangeConditions(sets.doubleLossPerBalance, m_EdtLossPerBalance, "Floating loss rises to % of balance", 100);
}

// Processes edit of input-field of Condition "Floating loss falls to % of balance".
void CAccountProtector::OnEndEditLossPerBalanceReverse()
{
    EditChangeConditions(sets.doubleLossPerBalanceReverse, m_EdtLossPerBalanceReverse, "Floating loss falls to % of balance", 100);
}

// Processes edit of input-field of Condition "Floating loss rises to currency units".
void CAccountProtector::OnEndEditLossQuanUnits()
{
    EditChangeConditions(sets.doubleLossQuanUnits, m_EdtLossQuanUnits, "Floating loss rises to currency units", AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds);
}

// Processes edit of input-field of Condition "Floating loss falls to currency units".
void CAccountProtector::OnEndEditLossQuanUnitsReverse()
{
    EditChangeConditions(sets.doubleLossQuanUnitsReverse, m_EdtLossQuanUnitsReverse, "Floating loss falls to currency units", AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds);
}

// Processes edit of input-field of Condition "Floating loss rises to points".
void CAccountProtector::OnEndEditLossPoints()
{
    EditChangeConditions(sets.intLossPoints, m_EdtLossPoints, "Floating loss rises to points");
}

// Processes edit of input-field of Condition "Floating loss falls to points".
void CAccountProtector::OnEndEditLossPointsReverse()
{
    EditChangeConditions(sets.intLossPointsReverse, m_EdtLossPointsReverse, "Floating loss falls to points");
}

// Processes edit of input-field of Condition "Floating profit rises to % of balance".
void CAccountProtector::OnEndEditProfPerBalance()
{
    EditChangeConditions(sets.doubleProfPerBalance, m_EdtProfPerBalance, "Floating profit rises to % of balance");
}

// Processes edit of input-field of Condition "Floating profit falls to % of balance".
void CAccountProtector::OnEndEditProfPerBalanceReverse()
{
    EditChangeConditions(sets.doubleProfPerBalanceReverse, m_EdtProfPerBalanceReverse, "Floating profit falls to % of balance");
}

// Processes edit of input-field of Condition "Floating profit rises to currency units".
void CAccountProtector::OnEndEditProfQuanUnits()
{
    EditChangeConditions(sets.doubleProfQuanUnits, m_EdtProfQuanUnits, "Floating profit rises to currency units");
}

// Processes edit of input-field of Condition "Floating profit falls to currency units".
void CAccountProtector::OnEndEditProfQuanUnitsReverse()
{
    EditChangeConditions(sets.doubleProfQuanUnitsReverse, m_EdtProfQuanUnitsReverse, "Floating profit falls to currency units");
}

// Processes edit of input-field of Condition "Floating profit rises points".
void CAccountProtector::OnEndEditProfPoints()
{
    EditChangeConditions(sets.intProfPoints, m_EdtProfPoints, "Floating profit reaches points");
}

// Processes edit of input-field of Condition "Floating profit rises to points".
void CAccountProtector::OnEndEditProfPointsReverse()
{
    EditChangeConditions(sets.intProfPointsReverse, m_EdtProfPointsReverse, "Floating profit falls to points");
}

// Processes edit of input-field of Condition "Equity <= currency units".
void CAccountProtector::OnEndEditEquityLessUnits()
{
    EditChangeConditions(sets.doubleEquityLessUnits, m_EdtEquityLessUnits, "Equity <= currency units", AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds);
}

// Processes edit of input-field of Condition "Equity >= currency units".
void CAccountProtector::OnEndEditEquityGrUnits()
{
    EditChangeConditions(sets.doubleEquityGrUnits, m_EdtEquityGrUnits, "Equity >= currency units");
}

// Processes edit of input-field of Condition "Equity <= % of snapshot".
void CAccountProtector::OnEndEditEquityLessPerSnap()
{
    EditChangeConditions(sets.doubleEquityLessPerSnap, m_EdtEquityLessPerSnap, "Equity <= % of snapshot", 100);
}

// Processes edit of input-field of Condition "Equity >= % of snapshot".
void CAccountProtector::OnEndEditEquityGrPerSnap()
{
    EditChangeConditions(sets.doubleEquityGrPerSnap, m_EdtEquityGrPerSnap, "Equity >= % of snapshot");
}

// Processes edit of input-field of Condition "Equity - Snapshot >= currency units".
void CAccountProtector::OnEndEditEquityMinusSnapshot()
{
    EditChangeConditions(sets.doubleEquityMinusSnapshot, m_EdtEquityMinusSnapshot, "Equity - Snapshot >= currency units");
}

// Processes edit of input-field of Condition "Snapshot - Equity >= currency units".
void CAccountProtector::OnEndEditSnapshotMinusEquity()
{
    EditChangeConditions(sets.doubleSnapshotMinusEquity, m_EdtSnapshotMinusEquity, "Snapshot - Equity >= currency units");
}

// Processes edit of input-field of Condition "Free margin <= currency units".
void CAccountProtector::OnEndEditMarginLessUnits()
{
    EditChangeConditions(sets.doubleMarginLessUnits, m_EdtMarginLessUnits, "Free margin <= currency units", AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds);
}

// Processes edit of input-field of Condition "Free margin >= currency units".
void CAccountProtector::OnEndEditMarginGrUnits()
{
    EditChangeConditions(sets.doubleMarginGrUnits, m_EdtMarginGrUnits, "Free margin >= currency units");
}

// Processes edit of input-field of Condition "Free margin <= % of snapshot".
void CAccountProtector::OnEndEditMarginLessPerSnap()
{
    EditChangeConditions(sets.doubleMarginLessPerSnap, m_EdtMarginLessPerSnap, "Free margin <= % of snapshot");
}

// Processes edit of input-field of Condition "Free margin >= % of snapshot".
void CAccountProtector::OnEndEditMarginGrPerSnap()
{
    EditChangeConditions(sets.doubleMarginGrPerSnap, m_EdtMarginGrPerSnap, "Free margin >= % of snapshot");
}

// Processes edit of input-field of Condition "Price >= value".
void CAccountProtector::OnEndEditPriceGE()
{
    EditChangeConditions(sets.doublePriceGE, m_EdtPriceGE, "Current price >=");
}

// Processes edit of input-field of Condition "Price <= value".
void CAccountProtector::OnEndEditPriceLE()
{
    EditChangeConditions(sets.doublePriceLE, m_EdtPriceLE, "Current price <=");
}

// Processes edit of input-field of Condition "Margin level >= % value".
void CAccountProtector::OnEndEditMarginLevelGE()
{
    EditChangeConditions(sets.doubleMarginLevelGE, m_EdtMarginLevelGE, "Margin level >= %");
}

// Processes edit of input-field of Condition "Margin level <= % value".
void CAccountProtector::OnEndEditMarginLevelLE()
{
    EditChangeConditions(sets.doubleMarginLevelLE, m_EdtMarginLevelLE, "Margin level <= %");
}

// Processes edit of input-field of Condition "Spread >= points".
void CAccountProtector::OnEndEditSpreadGE()
{
    EditChangeConditions(sets.intSpreadGE, m_EdtSpreadGE, "Spread >= points");
}

// Processes edit of input-field of Condition "Spread <= points".
void CAccountProtector::OnEndEditSpreadLE()
{
    EditChangeConditions(sets.intSpreadLE, m_EdtSpreadLE, "Spread <= points");
}

// Processes edit of input-field of Condition "Daily profit/loss >= currency units".
void CAccountProtector::OnEndEditDailyProfitLossUnitsGE()
{
    EditChangeConditions(sets.doubleDailyProfitLossUnitsGE, m_EdtDailyProfitLossUnitsGE, "Daily profit/loss >= currency units");
}

// Processes edit of input-field of Condition "Daily profit/loss <= currency units".
void CAccountProtector::OnEndEditDailyProfitLossUnitsLE()
{
    EditChangeConditions(sets.doubleDailyProfitLossUnitsLE, m_EdtDailyProfitLossUnitsLE, "Daily profit/loss <= currency units");
}

// Processes edit of input-field of Condition "Daily profit/loss >= points".
void CAccountProtector::OnEndEditDailyProfitLossPointsGE()
{
    EditChangeConditions(sets.intDailyProfitLossPointsGE, m_EdtDailyProfitLossPointsGE, "Daily profit/loss >= points");
}

// Processes edit of input-field of Condition "Daily profit/loss <= points".
void CAccountProtector::OnEndEditDailyProfitLossPointsLE()
{
    EditChangeConditions(sets.intDailyProfitLossPointsLE, m_EdtDailyProfitLossPointsLE, "Daily profit/loss <= points");
}

// Processes edit of input-field of Condition "Daily profit/loss >= %".
void CAccountProtector::OnEndEditDailyProfitLossPercGE()
{
    EditChangeConditions(sets.doubleDailyProfitLossPercGE, m_EdtDailyProfitLossPercGE, "Daily profit/loss >= %");
}

// Processes edit of input-field of Condition "Daily profit/loss <= %".
void CAccountProtector::OnEndEditDailyProfitLossPercLE()
{
    EditChangeConditions(sets.doubleDailyProfitLossPercLE, m_EdtDailyProfitLossPercLE, "Daily profit/loss <= %");
}

// Processes edit of input-field for percentage of volume to be close in Action "Close Positions".
void CAccountProtector::OnEndEditClosePercentage()
{
    double ValueFromEdit = StringToDouble(m_EdtClosePercentage.Text());

    if (!IsDouble(m_EdtClosePercentage.Text()))
    {
        Logging("Value is wrong: Close Percentage.");
        LoadSettingsFromDisk();
    }
    else if (ValueFromEdit > 100)
    {
        Logging("Close Percentage value must be lower or equal to 100.");
        LoadSettingsFromDisk();
    }
    else if (ValueFromEdit < 0)
    {
        Logging("Close Percentage value must be greater than 0.");
        LoadSettingsFromDisk();
    }
    else if (sets.doubleClosePercentage != ValueFromEdit)
    {
        sets.doubleClosePercentage = ValueFromEdit;
        if (sets.ClosePos)
        {
            sets.Triggered = false;
            sets.TriggeredTime = "";
        }
        SaveSettingsOnDisk();
    }
}

// Supplementary function to process changes to edit fields in the Main tab:
// 1. Check emptiness.
// 2. Check and log if int.
// 3. Save if different from current.
void CAccountProtector::EditChangeMain(int& SettingsEditValue, CEdit& Edit, const string FieldName)
{
    int ValueFromEdit = (int)StringToInteger(Edit.Text());

    if (!IsInteger(Edit.Text()))
    {
        Logging("Value is wrong: " + FieldName + ".");
        LoadSettingsFromDisk();
    }
    else if (SettingsEditValue != ValueFromEdit)
    {
        SettingsEditValue = ValueFromEdit;
        SaveSettingsOnDisk();
    }
}

// Processes edit of input-field of Trailing Start.
void CAccountProtector::OnEndEditTrailingStart()
{
    EditChangeMain(sets.intTrailingStart, m_EdtTrailingStart, "Profit value (points) to start trailing SL");
}

// Processes edit of input-field of Trailing Step.
void CAccountProtector::OnEndEditTrailingStep()
{
    EditChangeMain(sets.intTrailingStep, m_EdtTrailingStep, "Trailing SL value (points)");
}

// Processes edit of input-field of Break Even.
void CAccountProtector::OnEndEditBreakEven()
{
    EditChangeMain(sets.intBreakEven, m_EdtBreakEven, "Profit value (points) to set SL to breakeven");
}

// Processes edit of input-field of Break Even Extra.
void CAccountProtector::OnEndEditBreakEvenExtra()
{
    EditChangeMain(sets.intBreakEvenExtra, m_EdtBreakEvenExtra, "Breakeven extra profit value (points)");
}

// Processes edit of input-field of Equity Trailing Stop.
void CAccountProtector::OnEndEditEquityTrailingStop()
{
    double ValueFromEdit = StringToDouble(m_EdtEquityTrailingStop.Text());

    if (!IsDouble(m_EdtEquityTrailingStop.Text()))
    {
        Logging("Value is wrong: Equity trailing stop (hidden).");
        LoadSettingsFromDisk();
    }
    else if (sets.doubleEquityTrailingStop != ValueFromEdit)
    {
        sets.doubleEquityTrailingStop = ValueFromEdit;
        SaveSettingsOnDisk();
        m_EdtEquityTrailingStop.Text(DoubleToString(ValueFromEdit, 2));
    }
}

// Processes click on Emergency Button.
void CAccountProtector::OnClickBtnEmergency()
{
    Logging("Emergency button pressed!");
    if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
    {
        Logging_Condition_Is_Met();
        Close_All_Positions();
        Delete_All_Pending_Orders();
        // Toggle AutoTrading button. "2" in GetAncestor call is the "root window".
        SendMessageW(GetAncestor(WindowHandle(Symbol(), Period()), 2), WM_COMMAND, 33020, 0);
        sets.Triggered = false;
        sets.TriggeredTime = "";
        Logging("All positions closed, pending orders deleted, autotrading disabled.");
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::OnClickBtnDayOfWeek()
{
    if (!m_BtnDayOfWeek.IsEnabled()) return;
    switch(sets.TimerDayOfWeek)
    {
    case Any:
        sets.TimerDayOfWeek = Monday;
        break;
    case Monday:
        sets.TimerDayOfWeek = Tuesday;
        break;
    case Tuesday:
        sets.TimerDayOfWeek = Wednesday;
        break;
    case Wednesday:
        sets.TimerDayOfWeek = Thursday;
        break;
    case Thursday:
        sets.TimerDayOfWeek = Friday;
        break;
    case Friday:
        sets.TimerDayOfWeek = Saturday;
        break;
    case Saturday:
        sets.TimerDayOfWeek = Sunday;
        break;
    case Sunday:
        sets.TimerDayOfWeek = Any;
        break;
    default:
        sets.TimerDayOfWeek = Any;
        break;
    }
    m_BtnDayOfWeek.Text(EnumToString(sets.TimerDayOfWeek));
    RefreshValues();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::OnClickBtnPositionStatus()
{
    switch(sets.CloseWhichPositions)
    {
    case All:
        sets.CloseWhichPositions = Losing;
        break;
    case Losing:
        sets.CloseWhichPositions = Profitable;
        break;
    case Profitable:
        sets.CloseWhichPositions = All;
        break;
    default:
        sets.CloseWhichPositions = All;
        break;
    }
    m_BtnPositionStatus.Text(EnumToString(sets.CloseWhichPositions));
    RefreshValues();
}

//+-----------------------+
//| Working with settings |
//|+----------------------+

// Saves settings from the panel into a file.
bool CAccountProtector::SaveSettingsOnDisk()
{
    int fh = FileOpen(m_FileName, FILE_TXT | FILE_WRITE);
    if (fh == INVALID_HANDLE)
    {
        Logging("Failed to open file for writing: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
        return false;
    }

// Order does not matter.
    FileWrite(fh, "CountCommSwaps");
    FileWrite(fh, IntegerToString(sets.CountCommSwaps));
    FileWrite(fh, "UseTimer");
    FileWrite(fh, IntegerToString(sets.UseTimer));
    FileWrite(fh, "Timer");
    FileWrite(fh, sets.Timer);
    FileWrite(fh, "TimeLeft");
    FileWrite(fh, sets.TimeLeft);
    FileWrite(fh, "TimeType");
    FileWrite(fh, IntegerToString(sets.intTimeType));
    FileWrite(fh, "boolTrailingStart");
    FileWrite(fh, IntegerToString(sets.boolTrailingStart));
    FileWrite(fh, "intTrailingStart");
    FileWrite(fh, IntegerToString(sets.intTrailingStart));
    FileWrite(fh, "boolTrailingStep");
    FileWrite(fh, IntegerToString(sets.boolTrailingStep));
    FileWrite(fh, "intTrailingStep");
    FileWrite(fh, IntegerToString(sets.intTrailingStep));
    FileWrite(fh, "boolBreakEven");
    FileWrite(fh, IntegerToString(sets.boolBreakEven));
    FileWrite(fh, "intBreakEven");
    FileWrite(fh, IntegerToString(sets.intBreakEven));
    FileWrite(fh, "boolBreakEvenExtra");
    FileWrite(fh, IntegerToString(sets.boolBreakEvenExtra));
    FileWrite(fh, "intBreakEvenExtra");
    FileWrite(fh, IntegerToString(sets.intBreakEvenExtra));
    FileWrite(fh, "boolEquityTrailingStop");
    FileWrite(fh, IntegerToString(sets.boolEquityTrailingStop));
    FileWrite(fh, "doubleEquityTrailingStop");
    FileWrite(fh, DoubleToString(sets.doubleEquityTrailingStop, 2));
    FileWrite(fh, "doubleCurrentEquityStopLoss");
    FileWrite(fh, DoubleToString(sets.doubleCurrentEquityStopLoss, 2));
    FileWrite(fh, "SnapEquity");
    FileWrite(fh, DoubleToString(sets.SnapEquity, 2));
    FileWrite(fh, "SnapEquityTime");
    FileWrite(fh, sets.SnapEquityTime);
    FileWrite(fh, "SnapMargin");
    FileWrite(fh, DoubleToString(sets.SnapMargin, 2));
    FileWrite(fh, "SnapMarginTime");
    FileWrite(fh, sets.SnapMarginTime);
    FileWrite(fh, "intOrderCommentaryCondition");
    FileWrite(fh, IntegerToString(sets.intOrderCommentaryCondition));
    FileWrite(fh, "OrderCommentary");
    FileWrite(fh, sets.OrderCommentary);
    FileWrite(fh, "MagicNumbers");
    FileWrite(fh, sets.MagicNumbers);
    FileWrite(fh, "boolExcludeMagics");
    FileWrite(fh, IntegerToString(sets.boolExcludeMagics));
    FileWrite(fh, "intInstrumentFilter");
    FileWrite(fh, IntegerToString(sets.intInstrumentFilter));
    FileWrite(fh, "Instruments");
    FileWrite(fh, sets.Instruments);
    FileWrite(fh, "boolIgnoreLossTrades");
    FileWrite(fh, IntegerToString(sets.boolIgnoreLossTrades));
    FileWrite(fh, "boolIgnoreProfitTrades");
    FileWrite(fh, IntegerToString(sets.boolIgnoreProfitTrades));
    FileWrite(fh, "boolLossPerBalance");
    FileWrite(fh, IntegerToString(sets.boolLossPerBalance));
    FileWrite(fh, "boolLossPerBalanceReverse");
    FileWrite(fh, IntegerToString(sets.boolLossPerBalanceReverse));
    FileWrite(fh, "boolLossQuanUnits");
    FileWrite(fh, IntegerToString(sets.boolLossQuanUnits));
    FileWrite(fh, "boolLossQuanUnitsReverse");
    FileWrite(fh, IntegerToString(sets.boolLossQuanUnitsReverse));
    FileWrite(fh, "boolLossPoints");
    FileWrite(fh, IntegerToString(sets.boolLossPoints));
    FileWrite(fh, "boolLossPointsReverse");
    FileWrite(fh, IntegerToString(sets.boolLossPointsReverse));
    FileWrite(fh, "boolProfPerBalance");
    FileWrite(fh, IntegerToString(sets.boolProfPerBalance));
    FileWrite(fh, "boolProfPerBalanceReverse");
    FileWrite(fh, IntegerToString(sets.boolProfPerBalanceReverse));
    FileWrite(fh, "boolProfQuanUnits");
    FileWrite(fh, IntegerToString(sets.boolProfQuanUnits));
    FileWrite(fh, "boolProfQuanUnitsReverse");
    FileWrite(fh, IntegerToString(sets.boolProfQuanUnitsReverse));
    FileWrite(fh, "boolProfPoints");
    FileWrite(fh, IntegerToString(sets.boolProfPoints));
    FileWrite(fh, "boolProfPointsReverse");
    FileWrite(fh, IntegerToString(sets.boolProfPointsReverse));
    FileWrite(fh, "boolEquityLessUnits");
    FileWrite(fh, IntegerToString(sets.boolEquityLessUnits));
    FileWrite(fh, "boolEquityGrUnits");
    FileWrite(fh, IntegerToString(sets.boolEquityGrUnits));
    FileWrite(fh, "boolEquityLessPerSnap");
    FileWrite(fh, IntegerToString(sets.boolEquityLessPerSnap));
    FileWrite(fh, "boolEquityGrPerSnap");
    FileWrite(fh, IntegerToString(sets.boolEquityGrPerSnap));
    FileWrite(fh, "boolEquityMinusSnapshot");
    FileWrite(fh, IntegerToString(sets.boolEquityMinusSnapshot));
    FileWrite(fh, "boolSnapshotMinusEquity");
    FileWrite(fh, IntegerToString(sets.boolSnapshotMinusEquity));
    FileWrite(fh, "boolMarginLessUnits");
    FileWrite(fh, IntegerToString(sets.boolMarginLessUnits));
    FileWrite(fh, "boolMarginGrUnits");
    FileWrite(fh, IntegerToString(sets.boolMarginGrUnits));
    FileWrite(fh, "boolMarginLessPerSnap");
    FileWrite(fh, IntegerToString(sets.boolMarginLessPerSnap));
    FileWrite(fh, "boolMarginGrPerSnap");
    FileWrite(fh, IntegerToString(sets.boolMarginGrPerSnap));
    FileWrite(fh, "boolPriceGE");
    FileWrite(fh, IntegerToString(sets.boolPriceGE));
    FileWrite(fh, "boolPriceLE");
    FileWrite(fh, IntegerToString(sets.boolPriceLE));
    FileWrite(fh, "boolMarginLevelGE");
    FileWrite(fh, IntegerToString(sets.boolMarginLevelGE));
    FileWrite(fh, "boolMarginLevelLE");
    FileWrite(fh, IntegerToString(sets.boolMarginLevelLE));
    FileWrite(fh, "boolSpreadGE");
    FileWrite(fh, IntegerToString(sets.boolSpreadGE));
    FileWrite(fh, "boolSpreadLE");
    FileWrite(fh, IntegerToString(sets.boolSpreadLE));
    FileWrite(fh, "boolDailyProfitLossUnitsGE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossUnitsGE));
    FileWrite(fh, "boolDailyProfitLossUnitsLE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossUnitsLE));
    FileWrite(fh, "boolDailyProfitLossPointsGE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossPointsGE));
    FileWrite(fh, "boolDailyProfitLossPointsLE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossPointsLE));
    FileWrite(fh, "boolDailyProfitLossPercGE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossPercGE));
    FileWrite(fh, "boolDailyProfitLossPercLE");
    FileWrite(fh, IntegerToString(sets.boolDailyProfitLossPercLE));
    FileWrite(fh, "doubleLossPerBalance");
    FileWrite(fh, DoubleToString(sets.doubleLossPerBalance));
    FileWrite(fh, "doubleLossPerBalanceReverse");
    FileWrite(fh, DoubleToString(sets.doubleLossPerBalanceReverse));
    FileWrite(fh, "doubleLossQuanUnits");
    FileWrite(fh, DoubleToString(sets.doubleLossQuanUnits));
    FileWrite(fh, "doubleLossQuanUnitsReverse");
    FileWrite(fh, DoubleToString(sets.doubleLossQuanUnitsReverse));
    FileWrite(fh, "intLossPoints");
    FileWrite(fh, IntegerToString(sets.intLossPoints));
    FileWrite(fh, "intLossPointsReverse");
    FileWrite(fh, IntegerToString(sets.intLossPointsReverse));
    FileWrite(fh, "doubleProfPerBalance");
    FileWrite(fh, DoubleToString(sets.doubleProfPerBalance));
    FileWrite(fh, "doubleProfPerBalanceReverse");
    FileWrite(fh, DoubleToString(sets.doubleProfPerBalanceReverse));
    FileWrite(fh, "doubleProfQuanUnits");
    FileWrite(fh, DoubleToString(sets.doubleProfQuanUnits));
    FileWrite(fh, "doubleProfQuanUnitsReverse");
    FileWrite(fh, DoubleToString(sets.doubleProfQuanUnitsReverse));
    FileWrite(fh, "intProfPoints");
    FileWrite(fh, IntegerToString(sets.intProfPoints));
    FileWrite(fh, "intProfPointsReverse");
    FileWrite(fh, IntegerToString(sets.intProfPointsReverse));
    FileWrite(fh, "doubleEquityLessUnits");
    FileWrite(fh, DoubleToString(sets.doubleEquityLessUnits));
    FileWrite(fh, "doubleEquityGrUnits");
    FileWrite(fh, DoubleToString(sets.doubleEquityGrUnits));
    FileWrite(fh, "doubleEquityLessPerSnap");
    FileWrite(fh, DoubleToString(sets.doubleEquityLessPerSnap));
    FileWrite(fh, "doubleEquityGrPerSnap");
    FileWrite(fh, DoubleToString(sets.doubleEquityGrPerSnap));
    FileWrite(fh, "doubleEquityMinusSnapshot");
    FileWrite(fh, DoubleToString(sets.doubleEquityMinusSnapshot));
    FileWrite(fh, "doubleSnapshotMinusEquity");
    FileWrite(fh, DoubleToString(sets.doubleSnapshotMinusEquity));
    FileWrite(fh, "doubleMarginLessUnits");
    FileWrite(fh, DoubleToString(sets.doubleMarginLessUnits));
    FileWrite(fh, "doubleMarginGrUnits");
    FileWrite(fh, DoubleToString(sets.doubleMarginGrUnits));
    FileWrite(fh, "doubleMarginLessPerSnap");
    FileWrite(fh, DoubleToString(sets.doubleMarginLessPerSnap));
    FileWrite(fh, "doubleMarginGrPerSnap");
    FileWrite(fh, DoubleToString(sets.doubleMarginGrPerSnap));
    FileWrite(fh, "doublePriceGE");
    FileWrite(fh, DoubleToString(sets.doublePriceGE));
    FileWrite(fh, "doublePriceLE");
    FileWrite(fh, DoubleToString(sets.doublePriceLE));
    FileWrite(fh, "doubleMarginLevelGE");
    FileWrite(fh, DoubleToString(sets.doubleMarginLevelGE));
    FileWrite(fh, "doubleMarginLevelLE");
    FileWrite(fh, DoubleToString(sets.doubleMarginLevelLE));
    FileWrite(fh, "intSpreadGE");
    FileWrite(fh, IntegerToString(sets.intSpreadGE));
    FileWrite(fh, "intSpreadLE");
    FileWrite(fh, IntegerToString(sets.intSpreadLE));
    FileWrite(fh, "doubleDailyProfitLossUnitsGE");
    FileWrite(fh, DoubleToString(sets.doubleDailyProfitLossUnitsGE));
    FileWrite(fh, "doubleDailyProfitLossUnitsLE");
    FileWrite(fh, DoubleToString(sets.doubleDailyProfitLossUnitsLE));
    FileWrite(fh, "intDailyProfitLossPointsGE");
    FileWrite(fh, IntegerToString(sets.intDailyProfitLossPointsGE));
    FileWrite(fh, "intDailyProfitLossPointsLE");
    FileWrite(fh, IntegerToString(sets.intDailyProfitLossPointsLE));
    FileWrite(fh, "doubleDailyProfitLossPercGE");
    FileWrite(fh, DoubleToString(sets.doubleDailyProfitLossPercGE));
    FileWrite(fh, "doubleDailyProfitLossPercLE");
    FileWrite(fh, DoubleToString(sets.doubleDailyProfitLossPercLE));
    FileWrite(fh, "ClosePos");
    FileWrite(fh, IntegerToString(sets.ClosePos));
    FileWrite(fh, "doubleClosePercentage");
    FileWrite(fh, DoubleToString(sets.doubleClosePercentage));
    FileWrite(fh, "CloseWhichPositions");
    FileWrite(fh, IntegerToString(sets.CloseWhichPositions));
    FileWrite(fh, "DeletePend");
    FileWrite(fh, IntegerToString(sets.DeletePend));
    FileWrite(fh, "DisAuto");
    FileWrite(fh, IntegerToString(sets.DisAuto));
    FileWrite(fh, "SendMails");
    FileWrite(fh, IntegerToString(sets.SendMails));
    FileWrite(fh, "SendNotif");
    FileWrite(fh, IntegerToString(sets.SendNotif));
    FileWrite(fh, "ClosePlatform");
    FileWrite(fh, IntegerToString(sets.ClosePlatform));
    FileWrite(fh, "EnableAuto");
    FileWrite(fh, IntegerToString(sets.EnableAuto));
    FileWrite(fh, "RecaptureSnapshots");
    FileWrite(fh, IntegerToString(sets.RecaptureSnapshots));
    FileWrite(fh, "SelectedTab");
    FileWrite(fh, IntegerToString(sets.SelectedTab));
    FileWrite(fh, "Triggered");
    FileWrite(fh, IntegerToString(sets.Triggered));
    FileWrite(fh, "TriggeredTime");
    FileWrite(fh, sets.TriggeredTime);
    FileWrite(fh, "TimerDayOfWeek");
    FileWrite(fh, IntegerToString(sets.TimerDayOfWeek));

    // These are not part of settings but are panel-related input parameters.
    // When the EA is reloaded due to its input parameters change, these should be compared to the new values.
    // If the value is changed, it should be updated in the panel too.
    // Is indicator reloading due to the input parameters change?
    if (GlobalVariableGet("AP-" + IntegerToString(ChartID()) + "-Parameters") > 0)
    {
        FileWrite(fh, "Parameter_Instruments");
        FileWrite(fh, Instruments);
    }
    
    FileClose(fh);

    return true;
}

// Supplementary function to load changes to relevant fields in tabs:
// 1. Check checkbox setting.
// 2. Set checkbox mark, read only state, and background color.
// 3. Fill edit field.
void CAccountProtector::RefreshConditions(const bool SettingsCheckBoxValue, const double SettingsEditValue, CCheckBox& CheckBox, CEdit& Edit, const int decimal_places = 2)
{
    if (SettingsCheckBoxValue)
    {
        CheckBox.Checked(true);
    }
    else
    {
        CheckBox.Checked(false);
    }
    Edit.Text(DoubleToString(SettingsEditValue, decimal_places));
}

// Loads settings from a file to the panel.
bool CAccountProtector::LoadSettingsFromDisk()
{
    if (!FileIsExist(m_FileName)) return false;
    int fh = FileOpen(m_FileName, FILE_TXT | FILE_READ);
    if (fh == INVALID_HANDLE)
    {
        Logging("Failed to open file for reading: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
        return false;
    }

    while (!FileIsEnding(fh))
    {
        string var_name = FileReadString(fh);
        string var_content = FileReadString(fh);
        if (var_name == "CountCommSwaps")
            sets.CountCommSwaps = (bool)StringToInteger(var_content);
        else if (var_name == "UseTimer")
            sets.UseTimer = (bool)StringToInteger(var_content);
        else if (var_name == "Timer")
            sets.Timer = var_content;
        else if (var_name == "TimeLeft")
            sets.TimeLeft = var_content;
        else if (var_name == "intTimeType")
            sets.intTimeType = (int)StringToInteger(var_content);
        else if (var_name == "boolTrailingStart")
            sets.boolTrailingStart = (bool)StringToInteger(var_content);
        else if (var_name == "intTrailingStart")
            sets.intTrailingStart = (int)StringToInteger(var_content);
        else if (var_name == "boolTrailingStep")
            sets.boolTrailingStep = (bool)StringToInteger(var_content);
        else if (var_name == "intTrailingStep")
            sets.intTrailingStep = (int)StringToInteger(var_content);
        else if (var_name == "boolBreakEven")
            sets.boolBreakEven = (bool)StringToInteger(var_content);
        else if (var_name == "intBreakEven")
            sets.intBreakEven = (int)StringToInteger(var_content);
        else if (var_name == "boolBreakEvenExtra")
            sets.boolBreakEvenExtra = (bool)StringToInteger(var_content);
        else if (var_name == "intBreakEvenExtra")
            sets.intBreakEvenExtra = (int)StringToInteger(var_content);
        else if (var_name == "boolEquityTrailingStop")
            sets.boolEquityTrailingStop = (bool)StringToInteger(var_content);
        else if (var_name == "doubleEquityTrailingStop")
            sets.doubleEquityTrailingStop = StringToDouble(var_content);
        else if (var_name == "doubleCurrentEquityStopLoss")
            sets.doubleCurrentEquityStopLoss = StringToDouble(var_content);
        else if (var_name == "SnapEquity")
            sets.SnapEquity = StringToDouble(var_content);
        else if (var_name == "SnapEquityTime")
            sets.SnapEquityTime = var_content;
        else if (var_name == "SnapMargin")
            sets.SnapMargin = StringToDouble(var_content);
        else if (var_name == "SnapMarginTime")
            sets.SnapMarginTime = var_content;
        else if (var_name == "intOrderCommentaryCondition")
            sets.intOrderCommentaryCondition = (int)StringToInteger(var_content);
        else if (var_name == "OrderCommentary")
            sets.OrderCommentary = var_content;
        else if (var_name == "MagicNumbers")
            sets.MagicNumbers = var_content;
        else if (var_name == "boolExcludeMagics")
            sets.boolExcludeMagics = (bool)StringToInteger(var_content);
        else if (var_name == "intInstrumentFilter")
            sets.intInstrumentFilter = (int)StringToInteger(var_content);
        else if (var_name == "Instruments")
            sets.Instruments = var_content;
        else if (var_name == "boolIgnoreLossTrades")
            sets.boolIgnoreLossTrades = (bool)StringToInteger(var_content);
        else if (var_name == "boolIgnoreProfitTrades")
            sets.boolIgnoreProfitTrades = (bool)StringToInteger(var_content);
        else if (var_name == "boolLossPerBalance")
        {
            if (!DisableFloatLossRisePerc) sets.boolLossPerBalance = (bool)StringToInteger(var_content);
            else sets.boolLossPerBalance = false;
        }
        else if (var_name == "boolLossPerBalanceReverse")
        {
            if (!DisableFloatLossFallPerc) sets.boolLossPerBalanceReverse = (bool)StringToInteger(var_content);
            else sets.boolLossPerBalanceReverse = false;
        }
        else if (var_name == "boolLossQuanUnits")
        {
            if (!DisableFloatLossRiseCurr) sets.boolLossQuanUnits = (bool)StringToInteger(var_content);
            else sets.boolLossQuanUnits = false;
        }
        else if (var_name == "boolLossQuanUnitsReverse")
        {
            if (!DisableFloatLossFallCurr) sets.boolLossQuanUnitsReverse = (bool)StringToInteger(var_content);
            else sets.boolLossQuanUnitsReverse = false;
        }
        else if (var_name == "boolLossPoints")
        {
            if (!DisableFloatLossRisePoints) sets.boolLossPoints = (bool)StringToInteger(var_content);
            else sets.boolLossPoints = false;
        }
        else if (var_name == "boolLossPointsReverse")
        {
            if (!DisableFloatLossFallPoints) sets.boolLossPointsReverse = (bool)StringToInteger(var_content);
            else sets.boolLossPointsReverse = false;
        }
        else if (var_name == "boolProfPerBalance")
        {
            if (!DisableFloatProfitRisePerc) sets.boolProfPerBalance = (bool)StringToInteger(var_content);
            else sets.boolProfPerBalance = false;
        }
        else if (var_name == "boolProfPerBalanceReverse")
        {
            if (!DisableFloatProfitFallPerc) sets.boolProfPerBalanceReverse = (bool)StringToInteger(var_content);
            else sets.boolProfPerBalanceReverse = false;
        }
        else if (var_name == "boolProfQuanUnits")
        {
            if (!DisableFloatProfitRiseCurr) sets.boolProfQuanUnits = (bool)StringToInteger(var_content);
            else sets.boolProfQuanUnits = false;
        }
        else if (var_name == "boolProfQuanUnitsReverse")
        {
            if (!DisableFloatProfitFallCurr) sets.boolProfQuanUnitsReverse = (bool)StringToInteger(var_content);
            else sets.boolProfQuanUnitsReverse = false;
        }
        else if (var_name == "boolProfPoints")
        {
            if (!DisableFloatProfitRisePoints) sets.boolProfPoints = (bool)StringToInteger(var_content);
            else sets.boolProfPoints = false;
        }
        else if (var_name == "boolProfPointsReverse")
        {
            if (!DisableFloatProfitFallPoints) sets.boolProfPointsReverse = (bool)StringToInteger(var_content);
            else sets.boolProfPointsReverse = false;
        }
        else if (var_name == "boolEquityLessUnits")
            sets.boolEquityLessUnits = (bool)StringToInteger(var_content);
        else if (var_name == "boolEquityGrUnits")
            sets.boolEquityGrUnits = (bool)StringToInteger(var_content);
        else if (var_name == "boolEquityLessPerSnap")
            sets.boolEquityLessPerSnap = (bool)StringToInteger(var_content);
        else if (var_name == "boolEquityGrPerSnap")
            sets.boolEquityGrPerSnap = (bool)StringToInteger(var_content);
        else if (var_name == "boolEquityMinusSnapshot")
        {
            if (!DisableEquityMinusSnapshot) sets.boolEquityMinusSnapshot = (bool)StringToInteger(var_content);
            else sets.boolEquityMinusSnapshot = false;
        }
        else if (var_name == "boolSnapshotMinusEquity")
        {
            if (!DisableSnapshotMinusEquity) sets.boolSnapshotMinusEquity = (bool)StringToInteger(var_content);
            else sets.boolSnapshotMinusEquity = false;
        }
        else if (var_name == "boolMarginLessUnits")
            sets.boolMarginLessUnits = (bool)StringToInteger(var_content);
        else if (var_name == "boolMarginGrUnits")
            sets.boolMarginGrUnits = (bool)StringToInteger(var_content);
        else if (var_name == "boolMarginLessPerSnap")
            sets.boolMarginLessPerSnap = (bool)StringToInteger(var_content);
        else if (var_name == "boolMarginGrPerSnap")
            sets.boolMarginGrPerSnap = (bool)StringToInteger(var_content);
        else if (var_name == "boolPriceGE")
        {
            if (!DisableCurrentPriceGE) sets.boolPriceGE = (bool)StringToInteger(var_content);
            else sets.boolPriceGE = false;
        }
        else if (var_name == "boolPriceLE")
        {
            if (!DisableCurrentPriceLE) sets.boolPriceLE = (bool)StringToInteger(var_content);
            else sets.boolPriceLE = false;
        }
        else if (var_name == "boolMarginLevelGE")
        {
            if (!DisableMarginLevelGE) sets.boolMarginLevelGE = (bool)StringToInteger(var_content);
            else sets.boolMarginLevelGE = false;
        }
        else if (var_name == "boolMarginLevelLE")
        {
            if (!DisableMarginLevelLE) sets.boolMarginLevelLE = (bool)StringToInteger(var_content);
            else sets.boolMarginLevelLE = false;
        }
        else if (var_name == "boolSpreadGE")
        {
            if (!DisableSpreadGE) sets.boolSpreadGE = (bool)StringToInteger(var_content);
            else sets.boolSpreadGE = false;
        }
        else if (var_name == "boolSpreadLE")
        {
            if (!DisableSpreadLE) sets.boolSpreadLE = (bool)StringToInteger(var_content);
            else sets.boolSpreadLE = false;
        }
        else if (var_name == "boolDailyProfitLossUnitsGE")
        {
            if (!DisableDailyProfitLossUnitsGE) sets.boolDailyProfitLossUnitsGE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossUnitsGE = false;
        }
        else if (var_name == "boolDailyProfitLossUnitsLE")
        {
            if (!DisableDailyProfitLossUnitsLE) sets.boolDailyProfitLossUnitsLE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossUnitsLE = false;
        }
        else if (var_name == "boolDailyProfitLossPointsGE")
        {
            if (!DisableDailyProfitLossPointsGE) sets.boolDailyProfitLossPointsGE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossPointsGE = false;
        }
        else if (var_name == "boolDailyProfitLossPointsLE")
        {
            if (!DisableDailyProfitLossPointsLE) sets.boolDailyProfitLossPointsLE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossPointsLE = false;
        }
        else if (var_name == "boolDailyProfitLossPercGE")
        {
            if (!DisableDailyProfitLossPercGE) sets.boolDailyProfitLossPercGE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossPercGE = false;
        }
        else if (var_name == "boolDailyProfitLossPercLE")
        {
            if (!DisableDailyProfitLossPercLE) sets.boolDailyProfitLossPercLE = (bool)StringToInteger(var_content);
            else sets.boolDailyProfitLossPercLE = false;
        }
        else if (var_name == "doubleLossPerBalance")
        {
            if (!DisableFloatLossRisePerc) sets.doubleLossPerBalance = StringToDouble(var_content);
            else sets.doubleLossPerBalance = 0;
        }
        else if (var_name == "doubleLossPerBalanceReverse")
        {
            if (!DisableFloatLossFallPerc) sets.doubleLossPerBalanceReverse = StringToDouble(var_content);
            else sets.doubleLossPerBalanceReverse = 0;
        }
        else if (var_name == "doubleLossQuanUnits")
        {
            if (!DisableFloatLossRiseCurr) sets.doubleLossQuanUnits = StringToDouble(var_content);
            else sets.doubleLossQuanUnits = 0;
        }
        else if (var_name == "doubleLossQuanUnitsReverse")
        {
            if (!DisableFloatLossFallCurr) sets.doubleLossQuanUnitsReverse = StringToDouble(var_content);
            else sets.doubleLossQuanUnitsReverse = 0;
        }
        else if (var_name == "intLossPoints")
        {
            if (!DisableFloatLossRisePoints) sets.intLossPoints = (int)StringToInteger(var_content);
            else sets.intLossPoints = 0;
        }
        else if (var_name == "intLossPointsReverse")
        {
            if (!DisableFloatLossFallPoints) sets.intLossPointsReverse = (int)StringToInteger(var_content);
            else sets.intLossPointsReverse = 0;
        }
        else if (var_name == "doubleProfPerBalance")
        {
            if (!DisableFloatProfitRisePerc) sets.doubleProfPerBalance = StringToDouble(var_content);
            else sets.doubleProfPerBalance = 0;
        }
        else if (var_name == "doubleProfPerBalanceReverse")
        {
            if (!DisableFloatProfitFallPerc) sets.doubleProfPerBalanceReverse = StringToDouble(var_content);
            else sets.doubleProfPerBalanceReverse = 0;
        }
        else if (var_name == "doubleProfQuanUnits")
        {
            if (!DisableFloatProfitRiseCurr) sets.doubleProfQuanUnits = StringToDouble(var_content);
            else sets.doubleProfQuanUnits = 0;
        }
        else if (var_name == "doubleProfQuanUnitsReverse")
        {
            if (!DisableFloatProfitFallCurr) sets.doubleProfQuanUnitsReverse = StringToDouble(var_content);
            else sets.doubleProfQuanUnitsReverse = 0;
        }
        else if (var_name == "intProfPoints")
        {
            if (!DisableFloatProfitRisePoints) sets.intProfPoints = (int)StringToInteger(var_content);
            else sets.intProfPoints = 0;
        }
        else if (var_name == "intProfPointsReverse")
        {
            if (!DisableFloatProfitFallPoints) sets.intProfPointsReverse = (int)StringToInteger(var_content);
            else sets.intProfPointsReverse = 0;
        }
        else if (var_name == "doubleEquityLessUnits")
            sets.doubleEquityLessUnits = StringToDouble(var_content);
        else if (var_name == "doubleEquityGrUnits")
            sets.doubleEquityGrUnits = StringToDouble(var_content);
        else if (var_name == "doubleEquityLessPerSnap")
            sets.doubleEquityLessPerSnap = StringToDouble(var_content);
        else if (var_name == "doubleEquityGrPerSnap")
            sets.doubleEquityGrPerSnap = StringToDouble(var_content);
        else if (var_name == "doubleEquityMinusSnapshot")
        {
            if (!DisableEquityMinusSnapshot) sets.doubleEquityMinusSnapshot = StringToDouble(var_content);
            else sets.doubleEquityMinusSnapshot = 0;
        }
        else if (var_name == "doubleSnapshotMinusEquity")
        {
            if (!DisableSnapshotMinusEquity) sets.doubleSnapshotMinusEquity = StringToDouble(var_content);
            else sets.doubleSnapshotMinusEquity = 0;
        }
        else if (var_name == "doubleMarginLessUnits")
            sets.doubleMarginLessUnits = StringToDouble(var_content);
        else if (var_name == "doubleMarginGrUnits")
            sets.doubleMarginGrUnits = StringToDouble(var_content);
        else if (var_name == "doubleMarginLessPerSnap")
            sets.doubleMarginLessPerSnap = StringToDouble(var_content);
        else if (var_name == "doubleMarginGrPerSnap")
            sets.doubleMarginGrPerSnap = StringToDouble(var_content);
        else if (var_name == "doublePriceGE")
        {
            if (!DisableCurrentPriceGE) sets.doublePriceGE = StringToDouble(var_content);
            else sets.doublePriceGE = 0;
        }
        else if (var_name == "doublePriceLE")
        {
            if (!DisableCurrentPriceLE) sets.doublePriceLE = StringToDouble(var_content);
            else sets.doublePriceLE = 0;
        }
        else if (var_name == "doubleMarginLevelGE")
        {
            if (!DisableMarginLevelGE) sets.doubleMarginLevelGE = StringToDouble(var_content);
            else sets.doubleMarginLevelGE = 0;
        }
        else if (var_name == "doubleMarginLevelLE")
        {
            if (!DisableMarginLevelLE) sets.doubleMarginLevelLE = StringToDouble(var_content);
            else sets.doubleMarginLevelLE = 0;
        }
        else if (var_name == "intSpreadGE")
        {
            if (!DisableSpreadGE) sets.intSpreadGE = (int)StringToInteger(var_content);
            else sets.intSpreadGE = 0;
        }
        else if (var_name == "intSpreadLE")
        {
            if (!DisableSpreadLE) sets.intSpreadLE = (int)StringToInteger(var_content);
            else sets.intSpreadLE = 0;
        }
        else if (var_name == "doubleDailyProfitLossUnitsGE")
        {
            if (!DisableDailyProfitLossUnitsGE) sets.doubleDailyProfitLossUnitsGE = StringToDouble(var_content);
            else sets.doubleDailyProfitLossUnitsGE = 0;
        }
        else if (var_name == "doubleDailyProfitLossUnitsLE")
        {
            if (!DisableDailyProfitLossUnitsLE) sets.doubleDailyProfitLossUnitsLE = StringToDouble(var_content);
            else sets.doubleDailyProfitLossUnitsLE = 0;
        }
        else if (var_name == "intDailyProfitLossPointsGE")
        {
            if (!DisableDailyProfitLossPointsGE) sets.intDailyProfitLossPointsGE = (int)StringToInteger(var_content);
            else sets.intDailyProfitLossPointsGE = 0;
        }
        else if (var_name == "intDailyProfitLossPointsLE")
        {
            if (!DisableDailyProfitLossPointsLE) sets.intDailyProfitLossPointsLE = (int)StringToInteger(var_content);
            else sets.intDailyProfitLossPointsLE = 0;
        }
        else if (var_name == "doubleDailyProfitLossPercGE")
        {
            if (!DisableDailyProfitLossPercGE) sets.doubleDailyProfitLossPercGE = StringToDouble(var_content);
            else sets.doubleDailyProfitLossPercGE = 0;
        }
        else if (var_name == "doubleDailyProfitLossPercLE")
        {
            if (!DisableDailyProfitLossPercLE) sets.doubleDailyProfitLossPercLE = StringToDouble(var_content);
            else sets.doubleDailyProfitLossPercLE = 0;
        }
        else if (var_name == "ClosePos")
            sets.ClosePos = (bool)StringToInteger(var_content);
        else if (var_name == "doubleClosePercentage")
            sets.doubleClosePercentage = StringToDouble(var_content);
        else if (var_name == "CloseWhichPositions")
            sets.CloseWhichPositions = (Position_Status)StringToInteger(var_content);
        else if (var_name == "DeletePend")
            sets.DeletePend = (bool)StringToInteger(var_content);
        else if (var_name == "DisAuto")
            sets.DisAuto = (bool)StringToInteger(var_content);
        else if (var_name == "SendMails")
            sets.SendMails = (bool)StringToInteger(var_content);
        else if (var_name == "SendNotif")
            sets.SendNotif = (bool)StringToInteger(var_content);
        else if (var_name == "ClosePlatform")
            sets.ClosePlatform = (bool)StringToInteger(var_content);
        else if (var_name == "EnableAuto")
            sets.EnableAuto = (bool)StringToInteger(var_content);
        else if (var_name == "EnableAuto")
            sets.EnableAuto = (bool)StringToInteger(var_content);
        else if (var_name == "RecaptureSnapshots")
            sets.RecaptureSnapshots = (TABS)StringToInteger(var_content);
        else if (var_name == "Triggered")
            sets.Triggered = (bool)StringToInteger(var_content);
        else if (var_name == "TriggeredTime")
            sets.TriggeredTime = var_content;
        else if (var_name == "TimerDayOfWeek")
            sets.TimerDayOfWeek = (Day_of_Week)StringToInteger(var_content);

        // Is the EA reloading due to the input parameters change?
        if (GlobalVariableGet("AP-" + IntegerToString(ChartID()) + "-Parameters") > 0)
        {
            // These are not part of settings but are panel-related input parameters.
            // When the EA is reloaded due to its input parameters change, these should be compared to the new values.
            // If the value is changed, it should be updated in the panel too.
            if (var_name == "Parameter_Instruments")
            {
                if (var_content != Instruments) sets.Instruments = Instruments;
            }
        }
    }

    FileClose(fh);

    // Refreshing panel controls.
    RefreshPanelControls();

    // Is the EA reloading due to the input parameters change? Delete the flag variable.
    if (GlobalVariableGet("AP-" + IntegerToString(ChartID()) + "-Parameters") > 0) GlobalVariableDel("AP-" + IntegerToString(ChartID()) + "-Parameters");

    return true;
}

// Deletes the settings file.
bool CAccountProtector::DeleteSettingsFile()
{
    if (!FileIsExist(m_FileName)) return false;
    if (!FileDelete(m_FileName))
    {
        Logging("Failed to delete file: " + m_FileName + ". Error: " + IntegerToString(GetLastError()));
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAccountProtector::HideShowMaximize(bool max = true)
{
    // Remember the panel's location.
    remember_left = Left();
    remember_top = Top();

    Hide();
    Show();
    if (!max) NoPanelMaximization = true;
    else NoPanelMaximization = false;
    Maximize();
}

//+------------------------------------------------+
//|                                                |
//|              Operational Functions             |
//|                                                |
//+------------------------------------------------+

// Checks EA status.
void CAccountProtector::Check_Status()
{
    if (sets.Triggered) return;
    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED)))
    {
        m_LblStatus.Text("Status: Autotrading is disabled.");
        return;
    }
    else if ((!MQLInfoInteger(MQL_DLLS_ALLOWED)) && ((sets.DisAuto) || (sets.EnableAuto)))
    {
        m_LblStatus.Text("Status: DLLs are disabled.");
        return;
    }
    else if (No_Condition())
    {
        m_LblStatus.Text("Status: No condition set.");
        return;
    }
    else if (No_Action())
    {
        m_LblStatus.Text("Status: No action set.");
        return;
    }
    m_LblStatus.Text("Status: OK.");
    return;
}

// Checks if there is no condition set.
bool CAccountProtector::No_Condition()
{
    if ((!sets.UseTimer) &&
            (!sets.boolProfPerBalance) && (!sets.boolProfQuanUnits) && (!sets.boolProfPoints) &&
            (!sets.boolLossPerBalance) && (!sets.boolLossQuanUnits) && (!sets.boolLossPoints) &&
            (!sets.boolProfPerBalanceReverse) && (!sets.boolProfQuanUnitsReverse) && (!sets.boolProfPointsReverse) &&
            (!sets.boolLossPerBalanceReverse) && (!sets.boolLossQuanUnitsReverse) && (!sets.boolLossPointsReverse) &&
            (!sets.boolEquityLessUnits) && (!sets.boolEquityGrUnits) && (!sets.boolEquityLessPerSnap) && (!sets.boolEquityGrPerSnap) && (!sets.boolEquityMinusSnapshot) && (!sets.boolSnapshotMinusEquity) &&
            (!sets.boolMarginLessUnits) && (!sets.boolMarginGrUnits) && (!sets.boolMarginLessPerSnap) && (!sets.boolMarginGrPerSnap) &&
            (!sets.boolPriceGE) && (!sets.boolPriceLE) &&
            (!sets.boolMarginLevelGE) && (!sets.boolMarginLevelLE) &&
            (!sets.boolSpreadGE) && (!sets.boolSpreadLE) &&
            (!sets.boolDailyProfitLossUnitsGE) && (!sets.boolDailyProfitLossUnitsLE) && (!sets.boolDailyProfitLossPointsGE) && (!sets.boolDailyProfitLossPointsLE) && (!sets.boolDailyProfitLossPercGE) && (!sets.boolDailyProfitLossPercLE)
       ) return true;

    return false;
}

// Checks if there is no action set.
bool CAccountProtector::No_Action()
{
    if ((!sets.ClosePos) && (!sets.DeletePend) && (!sets.DisAuto) && (!sets.SendMails) && (!sets.SendNotif) && (!sets.ClosePlatform) && (!sets.EnableAuto) && (!sets.RecaptureSnapshots)) return true;

    return false;
}

// Calculates TimeLeft (to trigger actions "Timeout by Timer").
string CAccountProtector::NewTime()
{
    datetime chosen_time;
    int currtime, timertime, time, mod_time_60;
    string hour, minute;
    MqlDateTime currenttime_struct, timertime_struct;

    if (sets.intTimeType == 0) chosen_time = TimeCurrent();
    else chosen_time = TimeLocal();

    TimeToStruct(chosen_time, currenttime_struct);
    TimeToStruct(StringToTime(sets.Timer), timertime_struct);

    currtime = currenttime_struct.hour * 60 + currenttime_struct.min;
    timertime = timertime_struct.hour * 60 + timertime_struct.min;

    if (sets.TimerDayOfWeek == Any)
    {
        // Disregard day of the week.
        if (timertime == currtime) return("00:00");

        // This day or next day.
        if (timertime > currtime) time = timertime - currtime;
        else time = 1440 - currtime + timertime; // 1440 - minutes in a day.
    }
    else
    {
        int currdayofweek = currenttime_struct.day_of_week;
        if (currdayofweek == 0) currdayofweek = 7; // Make Sunday the 7th day.
        int timerdayofweek = (int)sets.TimerDayOfWeek;
        // Same day of the week - either later today or in one week.
        if (currdayofweek == timerdayofweek)
        {
            if (timertime == currtime) return("00:00");

            // This day or next week.
            if (timertime > currtime) time = timertime - currtime;
            else time = 10080 - currtime + timertime; // 10080 - minutes in a week.
        }
        else if (currdayofweek < timerdayofweek) // Timer is set to future day of the week.
        {
            if (timertime > currtime) // Now is 16:00, timer is for 18:00.
            {
                time = timertime - currtime;
                time += (timerdayofweek - currdayofweek) * 1440; // Add minutes for each day of difference.
            }
            else // Now is 23:00, timer is for 1:00.
            {
                time = 1440 - currtime + timertime; // 1440 - minutes in a day.
                time += (timerdayofweek - currdayofweek - 1) * 1440; // Add minutes for each day of difference except for the current one.
            }
        }
        else // Timer is set to a previous day of the week and thus should trigger on next week.
        {
            if (timertime >= currtime) // Now is 16:00, timer is for 18:00.
            {
                time = timertime - currtime;
                time += 10080 - (currdayofweek - timerdayofweek) * 1440; // Add hours for each day of difference.
            }
            else // Now is 23:00, timer is for 1:00.
            {
                time = 1440 - currtime + timertime; // 1440 - minutes in a day.
                time += 10080 - (currdayofweek - timerdayofweek + 1) * 1440; // Add minutes for each day of difference except for the current one.
            }
        }
    }

    string days_string = "";
    int days = time / 1440;

    if (days > 0) days_string = IntegerToString(days) + ":";

    time -= days * 1440; // Remove days from the time difference.

    mod_time_60 = (int)MathMod(time, 60);

    // Leading zero for hours.
    if ((time - mod_time_60) / 60 < 10) hour = "0" + DoubleToString((time - mod_time_60) / 60, 0);
    else hour = DoubleToString((time - mod_time_60) / 60, 0);

    // Leading zero for minutes
    if (mod_time_60 < 10) minute = "0" + DoubleToString(mod_time_60, 0);
    else minute = DoubleToString(mod_time_60, 0);

    return(days_string + hour + ":" + minute);
}

// Returns true if order should be filtered out based on its symbol and filter settings.
bool CAccountProtector::CheckFilterSymbol(string order_symbol)
{
    // Skip an order if instrument filter is set to 'Use only current trading instrument' and the Symbol is not the chart's current one.
    if (sets.intInstrumentFilter == 1)
    {
        if (order_symbol != Symbol()) return true;
    }
    // Skip an order if instrument filter is set to 'Exclude current trading instrument' and the Symbol is the same as the chart's current one.
    else if (sets.intInstrumentFilter == 2)
    {
        if (order_symbol == Symbol()) return true;
    }
    {
        StringToLower(order_symbol);
        // Skip if using an "Include" list and the symbol IS NOT found among the listed ones.
        if (sets.intInstrumentFilter == 3)
        {
            for (int i = 0; i < instruments_array_counter; i++)
            {
                if (order_symbol == Instruments_array[i]) return false; // Pass.
            }
            return true; // Didn't pass.
        }
        // Skip if using an "Exclude" list and the symbol IS found among the listed ones.
        else if (sets.intInstrumentFilter == 4)
        {
            for (int i = 0; i < instruments_array_counter; i++)
            {
                if (order_symbol == Instruments_array[i]) return true; // Didn't pass.
            }
            return false; // Pass.
        }
    }
    return false;
}

// Returns true if order should be filtered out based on its comment and filter settings.
bool CAccountProtector::CheckFilterComment(const string order_comment)
{
    // Skip an order if its commentary is not the same as filter value, and list view is set to "Equals".
    if ((order_comment != sets.OrderCommentary) && (sets.intOrderCommentaryCondition == 1)) return true;
    // Skip an order if its commentary is the same as filter value, and list view is set to "Not equal".
    if ((order_comment == sets.OrderCommentary) && (sets.intOrderCommentaryCondition == 3)) return true;
    // Skip an order if the filter value was given but was not found in order commentary, and list view is set to "Contains".
    if ((StringCompare(sets.OrderCommentary, "") != 0) && (StringFind(order_comment, sets.OrderCommentary) == -1) && (sets.intOrderCommentaryCondition == 0)) return true;
    // Skip an order if the filter value was given and was found in order commentary, and list view is set to "Does not contain".
    if ((StringCompare(sets.OrderCommentary, "") != 0) && (StringFind(order_comment, sets.OrderCommentary) >= 0) && (sets.intOrderCommentaryCondition == 2)) return true;

    return false;
}

// Returns true if order should be filtered out based on its magic number and filter settings. j - MagicNumbers_array cycle iteration.
bool CAccountProtector::CheckFilterMagic(const int magic, const int j)
{
    if (j == -1)
    {
        // There are some Magic numbers given but we are in a general cycle.
        if (magic_array_counter > 0) return true;
        // No Magic numbers given but "Exclude" option is checked, and we are in a general cycle.
        if ((magic == 0) && (sets.boolExcludeMagics)) return true;
    }
    else if (j >= 0)
    {
        // Skip order if its magic number is not in the array, and "Exclude" option is turned off.
        if ((magic != MagicNumbers_array[j]) && (!sets.boolExcludeMagics)) return true;
        // Skip order if its magic number is in the array, and "Exclude" option is turned on.
        if ((magic == MagicNumbers_array[j]) && (sets.boolExcludeMagics)) return true;
    }

    return false;
}

// Returns true if order should be filtered out based on its profit and filter settings.
inline bool CAccountProtector::CheckFilterLossProfit(const double order_profit)
{
    if ((sets.boolIgnoreLossTrades) && (order_profit < 0)) return true;
    if ((sets.boolIgnoreProfitTrades) && (order_profit > 0)) return true;
    return false;
}

// Closes all orders or deletes all pending orders.
void CAccountProtector::Close_All_Positions()
{
    int error = -1;
    bool AreAllOrdersEliminated = true;

    QuantityClosedMarketOrders = 0;
    IsANeedToContinueClosingOrders = false;

    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) return;

    // Check condition to know whether and how to sort PositionsByProfit.
    // Switching sorting modes because the array is traversed backwards - from total - 1 to 0.
    if ((TriggeredCondition == Floating_loss_rises_to_perecentage) || (TriggeredCondition == Floating_loss_rises_to_currency_units) || (TriggeredCondition == Floating_loss_rises_to_points)) ArraySort(PositionsByProfit, WHOLE_ARRAY, 0, MODE_DESCEND);
    else if ((TriggeredCondition == Floating_profit_rises_to_perecentage) || (TriggeredCondition == Floating_profit_rises_to_currency_units) || (TriggeredCondition == Floating_profit_rises_to_points)) ArraySort(PositionsByProfit, WHOLE_ARRAY, 0, MODE_ASCEND);
    // Otherwise no sorting needed.

    int total = ArrayRange(PositionsByProfit, 0); // We already have an array with all tickets.

    // Closing market orders. Going backwards to delete an order from the array after closing it.
    for (int i = total - 1; i >= 0; i--)
    {
        if (!OrderSelect((int)PositionsByProfit[i][1], SELECT_BY_TICKET))
        {
            error = GetLastError();
            Logging("Account Protector: OrderSelect by ticket failed " + IntegerToString(error) + ".");
            IsANeedToContinueClosingOrders = true;
            continue;
        }
        else if (SymbolInfoInteger(OrderSymbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
        {
            IsANeedToContinueClosingOrders = true;
            continue;
        }
        else
        {
            // No filter check is required because PositionsByProfit contains already filtered orders.
            // Skip profitable positions if only losing ones should be closed.
            if ((OrderProfit() >= 0) && (sets.CloseWhichPositions == Losing)) continue;
            // Skip losing positions if only profitable ones should be closed.
            if ((OrderProfit() < 0) && (sets.CloseWhichPositions == Profitable)) continue;
            double order_volume = OrderLots();
            if (OrderType() == OP_BUY)
            {
                error = Eliminate_Current_Order(OrderTicket());
                if (error != 0) Logging("Account Protector: OrderClose Buy failed. Error #" + IntegerToString(error));
                else
                {
                    QuantityClosedMarketOrders++;
                    ClosedVolume += order_volume;
                    ArrayResize(PositionsByProfit, i);
                }
            }
            else if (OrderType() == OP_SELL)
            {
                error = Eliminate_Current_Order(OrderTicket());
                if (error != 0) Logging("Account Protector: OrderClose Sell failed. Error #" + IntegerToString(error));
                else
                {
                    QuantityClosedMarketOrders++;
                    ClosedVolume += order_volume;
                    ArrayResize(PositionsByProfit, i);
                }
            }
        }
        // Using total volume closure with close percentage given.
        if ((UseTotalVolume) && (sets.doubleClosePercentage < 100))
        {
            // Check total volume closed vs. total volume before closure.
            if (ClosedVolume / TotalVolume * 100 >= sets.doubleClosePercentage)
            {
                // Stop closing positions.
                IsANeedToContinueClosingOrders = false;
                return;
            }
        }
        if (DelayOrderClose)
        {
           Logging("Sleeping " + IntegerToString(DelayOrderClose) + " ms before proceeding...");
           Sleep(DelayOrderClose);
        }
    }

    // Check if all orders have been eliminated.
    if (!IsANeedToContinueClosingOrders) return;

    AreAllOrdersEliminated = true;

    total = ArrayRange(PositionsByProfit, 0); // Take a new size because some positions have been closed.

    for (int i = 0; i < total; i++)
    {
        if (OrderSelect((int)PositionsByProfit[i][1], SELECT_BY_TICKET)) // Some (most) selects will fail because orders are already closed, but that's OK.
        {
            // Skip profitable positions if only losing ones should be closed.
            if ((OrderProfit() >= 0) && (sets.CloseWhichPositions == Losing)) continue;
            // Skip losing positions if only profitable ones should be closed.
            if ((OrderProfit() < 0) && (sets.CloseWhichPositions == Profitable)) continue;

            if (sets.doubleClosePercentage < 100)
            {
                // Check for partial close.
                // Extract previous order ticket from the comment.
                string comment = OrderComment();
                int comment_pos = StringFind(comment, "from #");
                if (comment_pos != -1)
                {
                    // Partial close already performed for this order.
                    if (PartiallyClosedOrders.Search(StringToInteger(StringSubstr(comment, comment_pos + 6))) != -1) continue;
                }
            }

            if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL))
            {
                AreAllOrdersEliminated = false;
                break;
            }
        }
    }

    if (AreAllOrdersEliminated)
    {
        IsANeedToContinueClosingOrders = false;
    }
}

// Deletes all pending orders.
void CAccountProtector::Delete_All_Pending_Orders()
{
    int error = -1;
    bool AreAllOrdersEliminated = true;

    QuantityDeletedPendingOrders = 0;
    IsANeedToContinueDeletingPendingOrders = false;

    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) return;

    // Closing market orders.
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (!OrderSelect(i, SELECT_BY_POS))
        {
            error = GetLastError();
            Logging("Account Protector: OrderSelect failed " + IntegerToString(error) + ".");
            IsANeedToContinueDeletingPendingOrders = true;
            continue;
        }
        else if (SymbolInfoInteger(OrderSymbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
        {
            IsANeedToContinueDeletingPendingOrders = true;
            continue;
        }
        else
        {
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;
                // Pending
                if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT) || (OrderType() == OP_BUYSTOP) || (OrderType() == OP_SELLSTOP))
                {
                    error = Eliminate_Current_Order(OrderTicket());
                    if (error != 0) Logging("Account Protector: OrderDelete failed. Error #" + IntegerToString(error));
                    else
                    {
                        Logging("Account Protector: " + OrderSymbol() + " Pending order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was deleted.");
                        QuantityDeletedPendingOrders++;
                    }
                    break; // Order already processed - no point to process this order with other magic numbers.
                }
            }
        }
        if (DelayOrderClose)
        {
           Logging("Sleeping " + IntegerToString(DelayOrderClose) + " ms before proceeding...");
           Sleep(DelayOrderClose);
        }
    }

    // Check if all orders have been eliminated.
    if (!IsANeedToContinueDeletingPendingOrders) return;

    AreAllOrdersEliminated = true;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (!OrderSelect(i, SELECT_BY_POS))
        {
            error = GetLastError();
            Logging("Account Protector: OrderSelect failed " + IntegerToString(error));
        }
        else
        {
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;

                if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT) || (OrderType() == OP_BUYSTOP) || (OrderType() == OP_SELLSTOP))
                {
                    AreAllOrdersEliminated = false;
                }
                break; // Order already processed - no point to process this order with other magic numbers.
            }
            if (!AreAllOrdersEliminated) break;
        }
    }

    if (AreAllOrdersEliminated)
    {
        IsANeedToContinueDeletingPendingOrders = false;
    }
}

// Closes an order or deletes a pending order by ticket number.
int CAccountProtector::Eliminate_Current_Order(int ticket)
{
    int error = -1;

    if (!OrderSelect(ticket, SELECT_BY_TICKET))
    {
        error = GetLastError();
        Logging("Account Protector: OrderSelect failed " + IntegerToString(error));
        return(error);
    }

    if (sets.doubleClosePercentage < 100) // Skip this part if closing whole positions.
    {
        // Extract previous order ticket from the comment.
        string comment = OrderComment();
        int comment_pos = StringFind(comment, "from #");
        if (comment_pos != -1)
        {
            // Partial close already performed for this order.
            if (PartiallyClosedOrders.Search(StringToInteger(StringSubstr(comment, comment_pos + 6))) != -1) return(0);
        }
    }
    
    if (OrderType() == OP_BUY)
    {
        double order_lots = OrderLots();
        double calculated_order_lots = CalculateOrderLots(order_lots, OrderSymbol());
        if (!OrderClose(OrderTicket(), calculated_order_lots, MarketInfo(OrderSymbol(), MODE_BID), Slippage, clrNONE))
        {
            IsANeedToContinueClosingOrders = true;
            return(GetLastError());
        }
        else
        {
            if (calculated_order_lots != order_lots)
            {
                Logging("Account Protector: " + OrderSymbol() + " Buy order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was partially closed (" + DoubleToString(sets.doubleClosePercentage) + "%) at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_BID), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                PartiallyClosedOrders.Add(OrderTicket());
                PartiallyClosedOrders.Sort();
            }
            else
            {
                Logging("Account Protector: " + OrderSymbol() + " Buy order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was closed at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_BID), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
            }
            return(0);
        }
    }
    if (OrderType() == OP_SELL)
    {
        double order_lots = OrderLots();
        double calculated_order_lots = CalculateOrderLots(order_lots, OrderSymbol());
        if (!OrderClose(OrderTicket(), CalculateOrderLots(OrderLots(), OrderSymbol()), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, clrNONE))
        {
            IsANeedToContinueClosingOrders = true;
            return(GetLastError());
        }
        else
        {
            if (calculated_order_lots != order_lots)
            {
                Logging("Account Protector: " + OrderSymbol() + " Sell order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was partially closed (" + DoubleToString(sets.doubleClosePercentage) + "%) at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_ASK), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                PartiallyClosedOrders.Add(OrderTicket());
                PartiallyClosedOrders.Sort();
            }
            else
            {
                Logging("Account Protector: " + OrderSymbol() + " Sell order #" + IntegerToString(OrderTicket()) + "; Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", SL = " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", TP = " + DoubleToString(OrderTakeProfit(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " was closed at " + DoubleToString(MarketInfo(OrderSymbol(), MODE_ASK), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
            }
            return(0);
        }
    }
    if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT) || (OrderType() == OP_BUYSTOP) || (OrderType() == OP_SELLSTOP))
        if (!OrderDelete(OrderTicket(), clrNONE))
        {
            IsANeedToContinueDeletingPendingOrders = true;
            return(GetLastError());
        }
        else return(0);

    return(-1);
}

// Trails stop-losses for all positions.
void CAccountProtector::Trailing()
{
    double SL, trailing_start = 0;

    if ((!sets.boolTrailingStep) || (sets.intTrailingStep == 0)) return;
    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) return;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS)) Logging("Account Protector: OrderSelect failed " + IntegerToString(GetLastError()) + ".");
        else if (SymbolInfoInteger(OrderSymbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED) continue;
        else
        {
            if (CheckFilterLossProfit(OrderProfit())) continue;
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;

                if (sets.boolTrailingStart == 0) trailing_start = 0;
                else trailing_start = sets.intTrailingStart * MarketInfo(OrderSymbol(), MODE_POINT);

                if (OrderType() == OP_BUY)
                {
                    if (MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice() >= trailing_start)
                    {
                        SL = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID) - sets.intTrailingStep * MarketInfo(OrderSymbol(), MODE_POINT), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
                        if (SL > OrderStopLoss())
                        {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration()))
                                Logging("Account Protector: OrderModify Buy failed " + IntegerToString(GetLastError()) + ".");
                            else
                                Logging("Account Protector: Trailing stop was applied to position - " + OrderSymbol() + " BUY-order #" + IntegerToString(OrderTicket()) + " Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", Stop-Loss was moved from " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " to " + DoubleToString(SL, (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                        }
                    }
                }
                else if (OrderType() == OP_SELL)
                {
                    if (OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK) >= trailing_start)
                    {
                        SL = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK) + sets.intTrailingStep * MarketInfo(OrderSymbol(), MODE_POINT), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
                        if ((SL < OrderStopLoss()) || (OrderStopLoss() == 0))
                        {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration()))
                                Logging("Account Protector: OrderModify Sell failed " + IntegerToString(GetLastError()) + ".");
                            else
                                Logging("Account Protector: Trailing stop was applied to position - " + OrderSymbol() + " SELL-order #" + IntegerToString(OrderTicket()) + " Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", Stop-Loss was moved from " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " to " + DoubleToString(SL, (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                        }
                    }
                }
                break; // Order already processed - no point to process this order with other magic numbers.
            }
        }
    }
}

// Moves stop-loss to breakeven or breakeven with extra points of profit.
void CAccountProtector::MoveToBreakEven()
{
    double SL;

    if ((!sets.boolBreakEven) || (sets.intBreakEven == 0)) return;
    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) return;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS)) Logging("Account Protector: OrderSelect failed " + IntegerToString(GetLastError()) + ".");
        else if (SymbolInfoInteger(OrderSymbol(), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED) continue;
        else
        {
            if (CheckFilterLossProfit(OrderProfit())) continue;
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;

                if (OrderType() == OP_BUY)
                {
                    if (MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice() >= sets.intBreakEven * MarketInfo(OrderSymbol(), MODE_POINT))
                    {
                        if ((!sets.boolBreakEvenExtra) || (sets.intBreakEvenExtra == 0)) SL = OrderOpenPrice();
                        else SL = OrderOpenPrice() + sets.intBreakEvenExtra * MarketInfo(OrderSymbol(), MODE_POINT);
                        if (SL > OrderStopLoss())
                        {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration()))
                                Logging("Account Protector: OrderModify Buy failed " + IntegerToString(GetLastError()) + ".");
                            else
                                Logging("Account Protector: Breakeven was applied to position - " + OrderSymbol() + " BUY-order #" + IntegerToString(OrderTicket()) + " Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", Stop-Loss was moved from " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " to " + DoubleToString(SL, (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                        }
                    }
                }
                else if (OrderType() == OP_SELL)
                {
                    if (OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK) >= sets.intBreakEven * MarketInfo(OrderSymbol(), MODE_POINT))
                    {
                        if ((!sets.boolBreakEvenExtra) || (sets.intBreakEvenExtra == 0)) SL = OrderOpenPrice();
                        else SL = OrderOpenPrice() - sets.intBreakEvenExtra * MarketInfo(OrderSymbol(), MODE_POINT);
                        if ((SL < OrderStopLoss()) || (OrderStopLoss() == 0))
                        {
                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration()))
                                Logging("Account Protector: OrderModify Sell failed " + IntegerToString(GetLastError()) + ".");
                            else
                                Logging("Account Protector: Breakeven was applied to position - " + OrderSymbol() + " SELL-order #" + IntegerToString(OrderTicket()) + " Lotsize = " + DoubleToString(OrderLots(), 2) + ", OpenPrice = " + DoubleToString(OrderOpenPrice(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ", Stop-Loss was moved from " + DoubleToString(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + " to " + DoubleToString(SL, (int)MarketInfo(OrderSymbol(), MODE_DIGITS)) + ".");
                        }
                    }
                }
                break; // Order already processed - no point to process this order with other magic numbers.
            }
        }
    }
}

// Trails equity with a hidden equity stop-loss.
void CAccountProtector::EquityTrailing()
{
    if ((!sets.boolEquityTrailingStop) || (sets.doubleEquityTrailingStop <= 0)) return;
    if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!TerminalInfoInteger(TERMINAL_CONNECTED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) return;

    double AE = AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds;

    // If equity stop-loss has been hit - close all positions.
    if ((AE <= sets.doubleCurrentEquityStopLoss) && (sets.doubleCurrentEquityStopLoss != 0))
    {
        string AdditionalFunds_Asterisk = "";
        if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";
        Logging("Account Protector: Equity stop-loss of " + DoubleToString(sets.doubleCurrentEquityStopLoss, 2) + " hit at " + DoubleToString(AE, 2) + AdditionalFunds_Asterisk + ". Closing all positions.");
        Close_All_Positions();

        sets.boolEquityTrailingStop = false;
        m_ChkEquityTrailingStop.Checked(false);

        m_LblCurrentEquityStopLoss.Hide();
        m_BtnResetEquityStopLoss.Hide();

        SaveSettingsOnDisk();
        MoveAndResize();
    }
    // If equity stop-loss should be trailed - update the stop-loss.
    else if ((AE - sets.doubleEquityTrailingStop > sets.doubleCurrentEquityStopLoss) || (sets.doubleCurrentEquityStopLoss == 0))
    {
        double old_value = sets.doubleCurrentEquityStopLoss;
        sets.doubleCurrentEquityStopLoss = AE - sets.doubleEquityTrailingStop;
        SaveSettingsOnDisk();
        string account_currency = AccountCurrency();
        if (account_currency != "") m_LblCurrentEquityStopLoss.Text("Current equity stop-loss: " + DoubleToString(sets.doubleCurrentEquityStopLoss, 2) + " " + account_currency + ".");
        // There was no equity stop-loss - now there is. The status line should be added after the equity stop-loss setting line on the panel.
        if (old_value == 0) MoveAndResize();
    }
}

// Logs current settings into the .log file.
void CAccountProtector::Logging_Current_Settings()
{
    SilentLogging = true;
    Logging("Logging Current Parameters:");
    Logging("EnableEmergencyButton = " + EnumToString((Enable)EnableEmergencyButton));
    Logging("sets.CountCommSwaps = " + (string)sets.CountCommSwaps);
    Logging("sets.UseTimer = " + (string)sets.UseTimer);
    Logging("sets.Timer = " + sets.Timer);
    Logging("sets.TimerDayOfWeek = " + EnumToString(sets.TimerDayOfWeek));
    Logging("sets.TimeLeft = " + sets.TimeLeft);
    Logging("sets.intTimeType = " + IntegerToString(sets.intTimeType));
    Logging("sets.boolTrailingStart = " + (string)sets.boolTrailingStart);
    Logging("sets.intTrailingStart = " + IntegerToString(sets.intTrailingStart));
    Logging("sets.boolTrailingStep = " + (string)sets.boolTrailingStep);
    Logging("sets.intTrailingStep = " + IntegerToString(sets.intTrailingStep));
    Logging("sets.boolBreakEven = " + (string)sets.boolBreakEven);
    Logging("sets.intBreakEven = " + IntegerToString(sets.intBreakEven));
    Logging("sets.boolBreakEvenExtra = " + (string)sets.boolBreakEvenExtra);
    Logging("sets.intBreakEvenExtra = " + IntegerToString(sets.intBreakEvenExtra));
    Logging("sets.SnapEquity = " + DoubleToString(sets.SnapEquity, 2));
    Logging("sets.SnapEquityTime = " + sets.SnapEquityTime);
    Logging("sets.SnapMargin = " + DoubleToString(sets.SnapMargin, 2));
    Logging("sets.SnapMarginTime = " + sets.SnapMarginTime);
    Logging("sets.intOrderCommentaryCondition = " + IntegerToString(sets.intOrderCommentaryCondition));
    Logging("sets.OrderCommentary = " + sets.OrderCommentary);
    Logging("sets.MagicNumbers = " + sets.MagicNumbers);
    Logging("sets.boolExcludeMagics = " + (string)sets.boolExcludeMagics);
    Logging("sets.intInstrumentFilter = " + IntegerToString(sets.intInstrumentFilter));
    Logging("sets.Instruments = " + sets.Instruments);
    Logging("sets.boolIgnoreLossTrades = " + (string)sets.boolIgnoreLossTrades);
    Logging("sets.boolIgnoreProfitTrades = " + (string)sets.boolIgnoreProfitTrades);
    Logging("sets.boolLossPerBalance = " + IntegerToString(sets.boolLossPerBalance));
    Logging("sets.boolLossPerBalancReversee = " + IntegerToString(sets.boolLossPerBalanceReverse));
    Logging("sets.boolLossQuanUnits = " + IntegerToString(sets.boolLossQuanUnits));
    Logging("sets.boolLossQuanUnitsReverse = " + IntegerToString(sets.boolLossQuanUnitsReverse));
    Logging("sets.boolLossPoints = " + IntegerToString(sets.boolLossPoints));
    Logging("sets.boolLossPointsReverse = " + IntegerToString(sets.boolLossPointsReverse));
    Logging("sets.boolProfPerBalance = " + IntegerToString(sets.boolProfPerBalance));
    Logging("sets.boolProfPerBalanceReverse = " + IntegerToString(sets.boolProfPerBalanceReverse));
    Logging("sets.boolProfQuanUnits = " + IntegerToString(sets.boolProfQuanUnits));
    Logging("sets.boolProfQuanUnitsReverse = " + IntegerToString(sets.boolProfQuanUnitsReverse));
    Logging("sets.boolProfPoints = " + IntegerToString(sets.boolProfPoints));
    Logging("sets.boolProfPointsReverse = " + IntegerToString(sets.boolProfPointsReverse));
    Logging("sets.boolEquityLessUnits = " + IntegerToString(sets.boolEquityLessUnits));
    Logging("sets.boolEquityGrUnits = " + IntegerToString(sets.boolEquityGrUnits));
    Logging("sets.boolEquityLessPerSnap = " + IntegerToString(sets.boolEquityLessPerSnap));
    Logging("sets.boolEquityGrPerSnap = " + IntegerToString(sets.boolEquityGrPerSnap));
    Logging("sets.boolEquityMinusSnapshot = " + IntegerToString(sets.boolEquityMinusSnapshot));
    Logging("sets.boolSnapshotMinusEquity = " + IntegerToString(sets.boolSnapshotMinusEquity));
    Logging("sets.boolMarginLessUnits = " + IntegerToString(sets.boolMarginLessUnits));
    Logging("sets.boolMarginGrUnits = " + IntegerToString(sets.boolMarginGrUnits));
    Logging("sets.boolMarginLessPerSnap = " + IntegerToString(sets.boolMarginLessPerSnap));
    Logging("sets.boolMarginGrPerSnap = " + IntegerToString(sets.boolMarginGrPerSnap));
    Logging("sets.boolPriceGE = " + IntegerToString(sets.boolPriceGE));
    Logging("sets.boolPriceLE = " + IntegerToString(sets.boolPriceLE));
    Logging("sets.boolMarginLevelGE = " + IntegerToString(sets.boolMarginLevelGE));
    Logging("sets.boolMarginLevelLE = " + IntegerToString(sets.boolMarginLevelLE));
    Logging("sets.boolSpreadGE = " + IntegerToString(sets.boolSpreadGE));
    Logging("sets.boolSpreadLE = " + IntegerToString(sets.boolSpreadLE));
    Logging("sets.boolDailyProfitLossUnitsGE = " + IntegerToString(sets.boolDailyProfitLossUnitsGE));
    Logging("sets.boolDailyProfitLossUnitsLE = " + IntegerToString(sets.boolDailyProfitLossUnitsLE));
    Logging("sets.boolDailyProfitLossPointsGE = " + IntegerToString(sets.boolDailyProfitLossPointsGE));
    Logging("sets.boolDailyProfitLossPointsLE = " + IntegerToString(sets.boolDailyProfitLossPointsLE));
    Logging("sets.boolDailyProfitLossPercGE = " + IntegerToString(sets.boolDailyProfitLossPercGE));
    Logging("sets.boolDailyProfitLossPercLE = " + IntegerToString(sets.boolDailyProfitLossPercLE));
    Logging("sets.doubleLossPerBalance = " + DoubleToString(sets.doubleLossPerBalance, 2));
    Logging("sets.doubleLossPerBalanceReverse = " + DoubleToString(sets.doubleLossPerBalanceReverse, 2));
    Logging("sets.doubleLossQuanUnits = " + DoubleToString(sets.doubleLossQuanUnits, 2));
    Logging("sets.doubleLossQuanUnitsReverse = " + DoubleToString(sets.doubleLossQuanUnitsReverse, 2));
    Logging("sets.intLossPoints = " + IntegerToString(sets.intLossPoints));
    Logging("sets.intLossPointsReverse = " + IntegerToString(sets.intLossPointsReverse));
    Logging("sets.doubleProfPerBalance = " + DoubleToString(sets.doubleProfPerBalance, 2));
    Logging("sets.doubleProfPerBalanceReverse = " + DoubleToString(sets.doubleProfPerBalanceReverse, 2));
    Logging("sets.doubleProfQuanUnits = " + DoubleToString(sets.doubleProfQuanUnits, 2));
    Logging("sets.doubleProfQuanUnitsReverse = " + DoubleToString(sets.doubleProfQuanUnitsReverse, 2));
    Logging("sets.intProfPoints = " + IntegerToString(sets.intProfPoints));
    Logging("sets.intProfPointsReverse = " + IntegerToString(sets.intProfPointsReverse));
    Logging("sets.doubleEquityLessUnits = " + DoubleToString(sets.doubleEquityLessUnits, 2));
    Logging("sets.doubleEquityGrUnits = " + DoubleToString(sets.doubleEquityGrUnits, 2));
    Logging("sets.doubleEquityLessPerSnap = " + DoubleToString(sets.doubleEquityLessPerSnap, 2));
    Logging("sets.doubleEquityGrPerSnap = " + DoubleToString(sets.doubleEquityGrPerSnap, 2));
    Logging("sets.doubleEquityMinusSnapshot = " + DoubleToString(sets.doubleEquityMinusSnapshot, 2));
    Logging("sets.doubleSnapshotMinusEquity = " + DoubleToString(sets.doubleSnapshotMinusEquity, 2));
    Logging("sets.doubleMarginLessUnits = " + DoubleToString(sets.doubleMarginLessUnits, 2));
    Logging("sets.doubleMarginGrUnits = " + DoubleToString(sets.doubleMarginGrUnits, 2));
    Logging("sets.doubleMarginLessPerSnap = " + DoubleToString(sets.doubleMarginLessPerSnap, 2));
    Logging("sets.doubleMarginGrPerSnap = " + DoubleToString(sets.doubleMarginGrPerSnap, 2));
    Logging("sets.doublePriceGE = " + DoubleToString(sets.doublePriceGE, _Digits));
    Logging("sets.doublePriceLE = " + DoubleToString(sets.doublePriceLE, _Digits));
    Logging("sets.doubleMarginLevelGE = " + DoubleToString(sets.doubleMarginLevelGE, 2) + "%");
    Logging("sets.doubleMarginLevelLE = " + DoubleToString(sets.doubleMarginLevelLE, 2) + "%");
    Logging("sets.intSpreadGE = " + IntegerToString(sets.intSpreadGE));
    Logging("sets.intSpreadLE = " + IntegerToString(sets.intSpreadLE));
    Logging("sets.doubleDailyProfitLossUnitsGE = " + DoubleToString(sets.doubleDailyProfitLossUnitsGE, 2));
    Logging("sets.doubleDailyProfitLossUnitsLE = " + DoubleToString(sets.doubleDailyProfitLossUnitsLE, 2));
    Logging("sets.intDailyProfitLossPointsGE = " + IntegerToString(sets.intDailyProfitLossPointsGE));
    Logging("sets.intDailyProfitLossPointsLE = " + IntegerToString(sets.intDailyProfitLossPointsLE));
    Logging("sets.doubleDailyProfitLossPercGE = " + DoubleToString(sets.doubleDailyProfitLossPercGE, 2));
    Logging("sets.doubleDailyProfitLossPercLE = " + DoubleToString(sets.doubleDailyProfitLossPercLE, 2));
    Logging("sets.ClosePos = " + IntegerToString(sets.ClosePos));
    Logging("sets.doubleClosePerecentage = " + DoubleToString(sets.doubleClosePercentage, 2) + "%");
    Logging("sets.CloseWhichPositions = " + EnumToString(sets.CloseWhichPositions));
    Logging("sets.DeletePend = " + IntegerToString(sets.DeletePend));
    Logging("sets.DisAuto = " + IntegerToString(sets.DisAuto));
    Logging("sets.SendMails = " + IntegerToString(sets.SendMails));
    Logging("sets.SendNotif = " + IntegerToString(sets.SendNotif));
    Logging("sets.ClosePlatform = " + IntegerToString(sets.ClosePlatform));
    Logging("sets.EnableAuto = " + IntegerToString(sets.EnableAuto));
    Logging("sets.RecaptureSnapshots = " + IntegerToString(sets.RecaptureSnapshots));
    Logging("sets.SelectedTab = " + EnumToString(sets.SelectedTab));
    Logging("sets.Log_file_name = " + LogFileName);
    Logging("------End Logging Current Parameters------");
    SilentLogging = false;
}

// Logs pre-condition values into the .log file and record positions into array.
void CAccountProtector::Logging_Condition_Is_Met()
{
    int i, market = 0, pending = 0;
    double floating_profit = 0;
    ClosedVolume = 0;
    TotalVolume = 0;
    if (LogFileName == "") return;
    for (i = 0; i < OrdersTotal(); i++)
        if (!OrderSelect(i, SELECT_BY_POS)) Logging("Account Protector: OrderSelect failed " + IntegerToString(GetLastError()));
        else
        {
            if (CheckFilterLossProfit(OrderProfit())) continue;
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;
                if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL))
                {
                    double order_floating_profit = OrderProfit();
                    if (sets.CountCommSwaps) order_floating_profit += OrderCommission() + OrderSwap();
                    floating_profit += order_floating_profit;
                    market++;
                    ArrayResize(PositionsByProfit, market, 100); // Reserve extra physical memory to increase the resizing speed.
                    PositionsByProfit[market - 1][0] = order_floating_profit;
                    PositionsByProfit[market - 1][1] = OrderTicket();
                    TotalVolume += OrderLots();
                }
                else if ((OrderType() == OP_BUYSTOP) || (OrderType() == OP_SELLSTOP) || (OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT)) pending++;
                break; // Order already processed - no point to process this order with other magic numbers.
            }
        }

    string AdditionalFunds_Asterisk = "";
    if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";

    Logging("Account Equity = " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Free Margin = " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ", Account Balance = " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY));
    if (floating_profit >= 0) Logging("Floating profit (filtered) = " + DoubleToString(floating_profit, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
    else Logging("Floating loss (filtered) = " + DoubleToString(floating_profit, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));
    Logging("Number of open positions (filtered) = " + IntegerToString(market) + ", Number of pending orders (filtered) = " + IntegerToString(pending) + ", Current spread = " + DoubleToString((double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * Point(), Digits()));
    Logging("Current trading instrument Bid/Ask = " + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_BID), _Digits) + "/" + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_ASK), _Digits));
}

// Prepares subject and body texts.
void CAccountProtector::PrepareSubjectBody(string &subject, string &body, const string title, const datetime timestamp, const int pos_closed, const int pend_deleted, const bool autotrade_dis, const bool push_sent, const bool mail_sent, const bool platf_closed, const bool autotrade_enabled, const bool snapshots_recaptured, const bool short_body = false)
{
    subject = AccountInfoString(ACCOUNT_COMPANY) + ", Account #" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ": " + title;
    body = TimeToString(timestamp, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    if (!short_body) body = "Account #" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + " at " + AccountInfoString(ACCOUNT_SERVER) + " of " + AccountInfoString(ACCOUNT_COMPANY) + ": " + title + " on " + body;
    if (pos_closed > 0)
    {
        body += "\r\n" + IntegerToString(pos_closed) + " position";
        if (pos_closed > 1) body += "s";
        body += " closed.";
    }
    if (pend_deleted > 0)
    {
        body += "\r\n" + IntegerToString(pend_deleted) + " pending order";
        if (pend_deleted > 1) body += "s";
        body += " deleted.";
    }
    if (autotrade_dis) body += "\r\nAutotrading disabled.";
    if (push_sent) body += "\r\nPush notifications sent.";
    else if (mail_sent) body += "\r\nEmail sent.";
    if (platf_closed) body += "\r\nPlatform closed.";
    if (autotrade_enabled) body += "\r\nAutotrading enabled.";
    if (snapshots_recaptured) body += "\r\nSnapshots recaptured.";
    if (LogFileName != "") body += "\r\nSee " + LogFileName + " for details.";
    body += "\r\n";
    body += "\r\nGenerated by Account Protector v." + Version + " (https://www.earnforex.com/).";
}

// Sends emails.
void CAccountProtector::SendMailFunction(string subject, string body)
{
    if (!SendMail(subject, body)) Logging("Account Protector failed to send an email.");
    else Logging("Email sent.");
}

// Sends push-notifications.
void CAccountProtector::SendNotificationFunction(string subject, string body)
{
    if (!SendNotification(subject)) Logging("Account Protector failed to send push notification about condition.");
    else Logging("Push notification about condition sent.");

    if (!SendNotification(body)) Logging("Account Protector failed to send push notification about actions.");
    else Logging("Push notification about actions sent.");
}

// Checks one condition.
template<typename T>
void CAccountProtector::CheckOneCondition(T &SettingsEditValue, bool &SettingsCheckboxValue, const string EventDescription, const ENUM_CONDITIONS triggered_condition = Other_condition)
{
    if (SettingsCheckboxValue)
    {
        Logging("CONDITION IS MET: " + EventDescription);
        TriggeredCondition = triggered_condition;
        Trigger_Actions(EventDescription);
        if (!DoNotResetConditions)
        {
            SettingsCheckboxValue = false;
            SettingsEditValue = 0;
        }
        SaveSettingsOnDisk();
        RefreshPanelControls();
    }
}

// Checks if some of the conditions are met.
void CAccountProtector::CheckAllConditions()
{
    double floating_profit = 0;
    int floating_profit_points = 0;
    double daily_profit_loss_units = 0, daily_profit_loss_perc = 0;
    int daily_profit_loss_points = 0;

    if (No_Condition() || No_Action()) return;

    // Calculating floating profit/loss.
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS))
        {
            Logging("Account Protector: MODE_TRADES OrderSelect failed " + IntegerToString(GetLastError()));
            continue;
        }

        if (CheckFilterLossProfit(OrderProfit())) continue;
        if (CheckFilterSymbol(OrderSymbol())) continue;
        if ((OrderClosePrice() == 0) || (iClose(OrderSymbol(), Period(), 0) == 0) || (SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK) == 0) || (SymbolInfoDouble(OrderSymbol(), SYMBOL_BID) == 0)) return; // Prevents incorrect profit/loss values when working with account that is traded via API calls.
        if (CheckFilterComment(OrderComment())) continue;
        // Starting from -1 index to check for orders irrespective of their Magic numbers.
        for (int j = -1; j < magic_array_counter; j++)
        {
            if (CheckFilterMagic(OrderMagicNumber(), j)) continue;

            floating_profit += OrderProfit();
            if (sets.CountCommSwaps) floating_profit += OrderCommission() + OrderSwap();

            if (OrderType() == OP_BUY) floating_profit_points += (int)MathRound((MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice()) / MarketInfo(OrderSymbol(), MODE_POINT));
            else if (OrderType() == OP_SELL) floating_profit_points += (int)MathRound((OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK)) / MarketInfo(OrderSymbol(), MODE_POINT));
            break; // Order already processed - no point to process this order with other magic numbers.
        }
    }
    
    // Calculating daily profit/loss if necessary.
    if (
        ((!DisableDailyProfitLossUnitsGE) && (sets.boolDailyProfitLossUnitsGE)) ||
        ((!DisableDailyProfitLossUnitsLE) && (sets.boolDailyProfitLossUnitsLE)) ||
        ((!DisableDailyProfitLossPointsGE) && (sets.boolDailyProfitLossPointsGE)) ||
        ((!DisableDailyProfitLossPointsLE) && (sets.boolDailyProfitLossPointsLE)) ||
        ((!DisableDailyProfitLossPercGE) && (sets.boolDailyProfitLossPercGE)) ||
        ((!DisableDailyProfitLossPercLE) && (sets.boolDailyProfitLossPercLE))
       )
    {
        datetime start_of_today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE)); // 00:00 of the current day by broker's time.
        for (int i = 0; i < OrdersHistoryTotal(); i++)
        {
            if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
            {
                Logging("Account Protector: MODE_HISTORY OrderSelect failed " + IntegerToString(GetLastError()));
                continue;
            }
    
            if (OrderCloseTime() < start_of_today) continue; // Older trade - skip.
            if (CheckFilterLossProfit(OrderProfit())) continue;
            if (CheckFilterSymbol(OrderSymbol())) continue;
            if (CheckFilterComment(OrderComment())) continue;
            // Starting from -1 index to check for orders irrespective of their Magic numbers.
            for (int j = -1; j < magic_array_counter; j++)
            {
                if (CheckFilterMagic(OrderMagicNumber(), j)) continue;
    
                daily_profit_loss_units += OrderProfit();
                if (sets.CountCommSwaps) daily_profit_loss_units += OrderCommission() + OrderSwap();
    
                if (OrderType() == OP_BUY) daily_profit_loss_points += (int)MathRound((OrderClosePrice() - OrderOpenPrice()) / MarketInfo(OrderSymbol(), MODE_POINT));
                else if (OrderType() == OP_SELL) daily_profit_loss_points += (int)MathRound((OrderOpenPrice() - OrderClosePrice()) / MarketInfo(OrderSymbol(), MODE_POINT));
                break; // Order already processed - no point to process this order with other magic numbers.
            }
        }
        // Current floating profit/loss is a part of the daily profit/loss.
        daily_profit_loss_units += floating_profit;
        daily_profit_loss_points += floating_profit_points;
        // Percentage of balance at the start of the day calculated by subtracting the current daily profit from the current balance.
        daily_profit_loss_perc = daily_profit_loss_units / (AccountInfoDouble(ACCOUNT_BALANCE) - daily_profit_loss_units) * 100;
    }

    string AdditionalFunds_Asterisk = "";
    if (AdditionalFunds != 0) AdditionalFunds_Asterisk = "*";

// Floating loss rose to <Actual percentage> % of balance.
    if ((!DisableFloatLossRisePerc) && (floating_profit <= -(AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds) * sets.doubleLossPerBalance / 100))
        CheckOneCondition(sets.doubleLossPerBalance, sets.boolLossPerBalance, "Floating loss rose to " + DoubleToString(sets.doubleLossPerBalance, 2) + "% of balance", Floating_loss_rises_to_perecentage);

// Floating loss fell to <Actual percentage> % of balance.
    if ((!DisableFloatLossFallPerc) && (floating_profit >= -(AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds) * sets.doubleLossPerBalanceReverse / 100))
        CheckOneCondition(sets.doubleLossPerBalanceReverse, sets.boolLossPerBalanceReverse, "Floating loss fell to " + DoubleToString(sets.doubleLossPerBalanceReverse, 2) + "% of balance");

// Floating loss rose to <Actual number> <currency ISO code>.
    if ((!DisableFloatLossRiseCurr) && (floating_profit <= -sets.doubleLossQuanUnits))
        CheckOneCondition(sets.doubleLossQuanUnits, sets.boolLossQuanUnits, "Floating loss rose to " + DoubleToString(sets.doubleLossQuanUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY), Floating_loss_rises_to_currency_units);

// Floating loss fell to <Actual number> <currency ISO code>.
    if ((!DisableFloatLossFallCurr) && (floating_profit >= -sets.doubleLossQuanUnitsReverse))
        CheckOneCondition(sets.doubleLossQuanUnitsReverse, sets.boolLossQuanUnitsReverse, "Floating loss fell to " + DoubleToString(sets.doubleLossQuanUnitsReverse, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Floating loss rose to <Actual number> points.
    if ((!DisableFloatLossRisePoints) && (floating_profit_points <= - sets.intLossPoints))
        CheckOneCondition(sets.intLossPoints, sets.boolLossPoints, "Floating loss rose to " + IntegerToString(sets.intLossPoints) + " points", Floating_loss_rises_to_points);

// Floating loss fell to <Actual number> points.
    if ((!DisableFloatLossFallPoints) && (floating_profit_points >= - sets.intLossPointsReverse))
        CheckOneCondition(sets.intLossPointsReverse, sets.boolLossPointsReverse, "Floating loss fell to " + IntegerToString(sets.intLossPointsReverse) + " points");

// Floating profit rose to <Actual percentage> % of balance.
    if ((!DisableFloatProfitRisePerc) && (floating_profit >= (AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds) * sets.doubleProfPerBalance / 100))
        CheckOneCondition(sets.doubleProfPerBalance, sets.boolProfPerBalance, "Floating profit rose to " + DoubleToString(sets.doubleProfPerBalance, 2) + "% of balance", Floating_profit_rises_to_perecentage);

// Floating profit fell to <Actual percentage> % of balance.
    if ((!DisableFloatProfitFallPerc) && (floating_profit <= (AccountInfoDouble(ACCOUNT_BALANCE) + AdditionalFunds) * sets.doubleProfPerBalanceReverse / 100))
        CheckOneCondition(sets.doubleProfPerBalanceReverse, sets.boolProfPerBalanceReverse, "Floating profit fell to " + DoubleToString(sets.doubleProfPerBalanceReverse, 2) + "% of balance");

// Floating profit rose to <Actual number> <currency ISO code>.
    if ((!DisableFloatProfitRiseCurr) && (floating_profit >= sets.doubleProfQuanUnits))
        CheckOneCondition(sets.doubleProfQuanUnits, sets.boolProfQuanUnits, "Floating profit rose to " + DoubleToString(sets.doubleProfQuanUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY), Floating_profit_rises_to_currency_units);

// Floating profit fell to <Actual number> <currency ISO code>.
    if ((!DisableFloatProfitFallCurr) && (floating_profit <= sets.doubleProfQuanUnitsReverse))
        CheckOneCondition(sets.doubleProfQuanUnitsReverse, sets.boolProfQuanUnitsReverse, "Floating profit fell to " + DoubleToString(sets.doubleProfQuanUnitsReverse, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Floating profit rose to <Actual number> points.
    if ((!DisableFloatProfitRisePoints) && (floating_profit_points >= sets.intProfPoints))
        CheckOneCondition(sets.intProfPoints, sets.boolProfPoints, "Floating profit rose to " + IntegerToString(sets.intProfPoints) + " points.", Floating_profit_rises_to_points);

// Floating profit fell to <Actual number> points.
    if ((!DisableFloatProfitFallPoints) && (floating_profit_points <= sets.intProfPointsReverse))
        CheckOneCondition(sets.intProfPointsReverse, sets.boolProfPointsReverse, "Floating profit fell to " + IntegerToString(sets.intProfPointsReverse) + " points.");

// Equity fell to <Actual number> <currency ISO code>.
    if (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds <= sets.doubleEquityLessUnits)
        CheckOneCondition(sets.doubleEquityLessUnits, sets.boolEquityLessUnits, "Equity fell to " + DoubleToString(sets.doubleEquityLessUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Equity rose to <Actual number> <currency ISO code>.
    if (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds >= sets.doubleEquityGrUnits)
        CheckOneCondition(sets.doubleEquityGrUnits, sets.boolEquityGrUnits, "Equity rose to " + DoubleToString(sets.doubleEquityGrUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Equity fell to <Actual percentage>% of previous snapshot (<snapshot value> <currency ISO code>).
    if (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds <= sets.SnapEquity * sets.doubleEquityLessPerSnap / 100)
        CheckOneCondition(sets.doubleEquityLessPerSnap, sets.boolEquityLessPerSnap, "Equity fell to " + DoubleToString(sets.doubleEquityLessPerSnap, 2) + "% of previous snapshot (" + DoubleToString(sets.SnapEquity, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ")");

// Equity rose to <Actual percentage>% of previous snapshot (<snapshot value> <currency ISO code>).
    if (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds >= sets.SnapEquity * sets.doubleEquityGrPerSnap / 100)
        CheckOneCondition(sets.doubleEquityGrPerSnap, sets.boolEquityGrPerSnap, "Equity rose to " + DoubleToString(sets.doubleEquityGrPerSnap, 2) + "% of previous snapshot (" + DoubleToString(sets.SnapEquity, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ")");

// Equity - Snapshot >= <Actual number> <currency ISO code>.
    if ((!DisableEquityMinusSnapshot) && (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds - sets.SnapEquity >= sets.doubleEquityMinusSnapshot))
        CheckOneCondition(sets.doubleEquityMinusSnapshot, sets.boolEquityMinusSnapshot, "Equity minus Snapshot => " + DoubleToString(sets.doubleEquityMinusSnapshot, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Snapshot - Equity >= <Actual number> <currency ISO code>.
    if ((!DisableSnapshotMinusEquity) && (sets.SnapEquity - (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds) >= sets.doubleSnapshotMinusEquity))
        CheckOneCondition(sets.doubleSnapshotMinusEquity, sets.boolSnapshotMinusEquity, "Snapshot minus Equity >= " + DoubleToString(sets.doubleSnapshotMinusEquity, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Free Margin fell to <Actual number> <currency ISO code>.
    if (AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds <= sets.doubleMarginLessUnits)
        CheckOneCondition(sets.doubleMarginLessUnits, sets.boolMarginLessUnits, "Free Margin fell to " + DoubleToString(sets.doubleMarginLessUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Free Margin rose to <Actual number> <currency ISO code>.
    if (AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds >= sets.doubleMarginGrUnits)
        CheckOneCondition(sets.doubleMarginGrUnits, sets.boolMarginGrUnits, "Free Margin rose to " + DoubleToString(sets.doubleMarginGrUnits, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Free Margin fell to <Actual percentage>% of previous snapshot (<snapshot value> <currency ISO code>).
    if (AccountInfoDouble(ACCOUNT_MARGIN_FREE) + AdditionalFunds <= sets.SnapMargin * sets.doubleMarginLessPerSnap / 100)
        CheckOneCondition(sets.doubleMarginLessPerSnap, sets.boolMarginLessPerSnap, "Free Margin fell to " + DoubleToString(sets.doubleMarginLessPerSnap, 2) + "% of previous snapshot (" + DoubleToString(sets.SnapMargin, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ")");

// Free Margin rose to <Actual percentage>% of previous snapshot (<snapshot value> <currency ISO code>).
    if (AccountInfoDouble(ACCOUNT_EQUITY) + AdditionalFunds >= sets.SnapMargin * sets.doubleMarginGrPerSnap / 100)
        CheckOneCondition(sets.doubleMarginGrPerSnap, sets.boolMarginGrPerSnap, "Free Margin rose to " + DoubleToString(sets.doubleMarginGrPerSnap, 2) + "% of previous snapshot (" + DoubleToString(sets.SnapMargin, 2) + AdditionalFunds_Asterisk + " " + AccountInfoString(ACCOUNT_CURRENCY) + ")");

// Current price greater or equal to <value>.
    if ((!DisableCurrentPriceGE) && (Ask >= sets.doublePriceGE))
        CheckOneCondition(sets.doublePriceGE, sets.boolPriceGE, "Current price greater or equal to " + DoubleToString(sets.doublePriceGE, _Digits));

// Current price less or equal to <value>.
    if ((!DisableCurrentPriceLE) && (Bid <= sets.doublePriceLE))
        CheckOneCondition(sets.doublePriceLE, sets.boolPriceLE, "Current price less or equal to " + DoubleToString(sets.doublePriceLE, _Digits));

// Margin level greater or equal to <value>%.
    if ((!DisableMarginLevelGE) && (AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) >= sets.doubleMarginLevelGE))
        CheckOneCondition(sets.doubleMarginLevelGE, sets.boolMarginLevelGE, "Margin level greater or equal to " + DoubleToString(sets.doubleMarginLevelGE, 2) + "%");

// Margin level less or equal to <value>%.
    if ((!DisableMarginLevelLE) && (AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) <= sets.doubleMarginLevelLE))
        CheckOneCondition(sets.doubleMarginLevelLE, sets.boolMarginLevelLE, "Margin level less or equal to " + DoubleToString(sets.doubleMarginLevelLE, 2) + "%");

// Spread greater or equal to <value> points.
    if ((!DisableSpreadGE) && (SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) >= sets.intSpreadGE))
        CheckOneCondition(sets.intSpreadGE, sets.boolSpreadGE, "Spread greater or equal to " + IntegerToString(sets.intSpreadGE));

// Spread less or equal to <value> points.
    if ((!DisableSpreadLE) && (SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) <= sets.intSpreadLE))
        CheckOneCondition(sets.intSpreadLE, sets.boolSpreadLE, "Spread less or equal to " + IntegerToString(sets.intSpreadLE));

// Daily profit/loss greater or equal to <value> currency units.
    if ((!DisableDailyProfitLossUnitsGE) && (daily_profit_loss_units >= sets.doubleDailyProfitLossUnitsGE))
        CheckOneCondition(sets.doubleDailyProfitLossUnitsGE, sets.boolDailyProfitLossUnitsGE, "Daily profit/loss greater or equal to " + DoubleToString(sets.doubleDailyProfitLossUnitsGE, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Daily profit/loss less or equal to <value> currency units.
    if ((!DisableDailyProfitLossUnitsLE) && (daily_profit_loss_units <= sets.doubleDailyProfitLossUnitsLE))
        CheckOneCondition(sets.doubleDailyProfitLossUnitsLE, sets.boolDailyProfitLossUnitsLE, "Daily profit/loss less or equal to " + DoubleToString(sets.doubleDailyProfitLossUnitsLE, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY));

// Daily profit/loss greater or equal to <value> points.
    if ((!DisableDailyProfitLossPointsGE) && (daily_profit_loss_points >= sets.intDailyProfitLossPointsGE))
        CheckOneCondition(sets.intDailyProfitLossPointsGE, sets.boolDailyProfitLossPointsGE, "Daily profit/loss greater or equal to " + IntegerToString(sets.intDailyProfitLossPointsGE));

// Daily profit/loss less or equal to <value> points.
    if ((!DisableDailyProfitLossPointsLE) && (daily_profit_loss_points <= sets.intDailyProfitLossPointsLE))
        CheckOneCondition(sets.intDailyProfitLossPointsLE, sets.boolDailyProfitLossPointsLE, "Daily profit/loss less or equal to " + IntegerToString(sets.intDailyProfitLossPointsLE));

// Daily profit/loss greater or equal to <value> %.
    if ((!DisableDailyProfitLossPercGE) && (daily_profit_loss_perc >= sets.doubleDailyProfitLossPercGE))
        CheckOneCondition(sets.doubleDailyProfitLossPercGE, sets.boolDailyProfitLossPercGE, "Daily profit/loss greater or equal to " + DoubleToString(sets.doubleDailyProfitLossPercGE, 2) + "%");

// Daily profit/loss less or equal to <value> %.
    if ((!DisableDailyProfitLossPercLE) && (daily_profit_loss_perc <= sets.doubleDailyProfitLossPercLE))
        CheckOneCondition(sets.doubleDailyProfitLossPercLE, sets.boolDailyProfitLossPercLE, "Daily profit/loss less or equal to " + DoubleToString(sets.doubleDailyProfitLossPercLE, 2) + "%");

// Timeout by timer.
    if ((sets.UseTimer) && (sets.TimeLeft == "00:00"))
    {
        string EventDescription = "Timeout by timer";
        Logging("CONDITION IS MET: " + EventDescription);
        Trigger_Actions(EventDescription);
        sets.UseTimer = false;
        SaveSettingsOnDisk();
        RefreshPanelControls();
    }
}

// Performs actions set by user.
void CAccountProtector::Trigger_Actions(string title)
{
    Logging_Condition_Is_Met();
    Logging_Current_Settings();

    if (sets.DisAuto) WasAutoTradingDisabled = true;
    else WasAutoTradingDisabled = false;

    if (sets.SendMails) WasMailSent = true;
    else WasMailSent = false;

    if (sets.SendNotif) WasNotificationSent = true;
    else WasNotificationSent = false;

    if (sets.ClosePlatform) WasPlatformClosed = true;
    else WasPlatformClosed = false;

    if (sets.EnableAuto) WasAutoTradingEnabled = true;
    else WasAutoTradingEnabled = false;

    if (sets.RecaptureSnapshots) WasRecapturedSnapshots = true;
    else WasRecapturedSnapshots = false;

    // Close all positions.
    if (sets.ClosePos)
    {
        if (!DoNotResetActions) sets.ClosePos = false;
        Logging("ACTION IS TAKEN: Close positions (" + DoubleToString(sets.doubleClosePercentage, 2) + "% of " + EnumToString(sets.CloseWhichPositions) + ").");
        PartiallyClosedOrders.Clear();
        Close_All_Positions();
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    // Delete all pending orders.
    if (sets.DeletePend)
    {
        if (!DoNotResetActions) sets.DeletePend = false;
        Logging("ACTION IS TAKEN: Delete all pending orders.");
        Delete_All_Pending_Orders();
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    // Disable autotrading.
    if (sets.DisAuto)
    {
        if (!DoNotResetActions) sets.DisAuto = false;
        Logging("ACTION IS TAKEN: Disable autotrading.");
        // Toggle AutoTrading button. "2" in GetAncestor call is the "root window".
        if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) SendMessageW(GetAncestor(WindowHandle(Symbol(), Period()), 2), WM_COMMAND, 33020, 0);
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    string subject, body;
    // Send emails.
    if (sets.SendMails)
    {
        if (!DoNotResetActions) sets.SendMails = false;
        Logging("ACTION IS TAKEN: Send email.");
        PrepareSubjectBody(subject, body, title, TimeCurrent(), QuantityClosedMarketOrders, QuantityDeletedPendingOrders, WasAutoTradingDisabled, WasNotificationSent, false, WasPlatformClosed, WasAutoTradingEnabled, WasRecapturedSnapshots);
        SendMailFunction(subject, body);
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    // Send push notifications.
    if (sets.SendNotif)
    {
        if (!DoNotResetActions) sets.SendNotif = false;
        Logging("ACTION IS TAKEN: Send push notifications.");
        PrepareSubjectBody(subject, body, title, TimeCurrent(), QuantityClosedMarketOrders, QuantityDeletedPendingOrders, WasAutoTradingDisabled, false, WasMailSent, WasPlatformClosed, WasAutoTradingEnabled, WasRecapturedSnapshots, true);
        SendNotificationFunction(subject, body);
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    // Close platform.
    if (sets.ClosePlatform)
    {
        if (!DoNotResetActions) sets.ClosePlatform = false;
        Logging("ACTION IS TAKEN: Close platform.");
        TerminalClose(0);
    }

    // Enable autotrading.
    if (sets.EnableAuto)
    {
        if (!DoNotResetActions) sets.EnableAuto = false;
        Logging("ACTION IS TAKEN: Enable autotrading.");
        // Toggle AutoTrading button. "2" in GetAncestor call is the "root window".
        if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) SendMessageW(GetAncestor(WindowHandle(Symbol(), Period()), 2), WM_COMMAND, 33020, 0);
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    // Recapture snapshots.
    if (sets.RecaptureSnapshots)
    {
        if (!DoNotResetActions) sets.RecaptureSnapshots = false;
        Logging("ACTION IS TAKEN: Recapture snapshots.");
        UpdateEquitySnapshot();
        UpdateMarginSnapshot();
        sets.Triggered = true;
        sets.TriggeredTime = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
    }

    SaveSettingsOnDisk();
    RefreshPanelControls();
}

// Saves information into a .log file and prints it to Experts tab.
void CAccountProtector::Logging(string message)
{
    if (StringLen(LogFileName) > 0)
    {
        string filename = LogFileName + ".log";
        if (LogFile < 0) LogFile = FileOpen(filename, FILE_CSV | FILE_READ | FILE_WRITE, ' ');
        if (LogFile < 1) Alert("Cannot open file for logging: ", filename, ".");
        else if (FileSeek(LogFile, 0, SEEK_END))
        {
            FileWrite(LogFile, TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES | TIME_SECONDS), " ", message);
            FileClose(LogFile);
            LogFile = -1;
        }
        else Alert("Unexpected error accessing file: ", filename, ".");
    }
    if (!SilentLogging) Print(message);
}

// Creates array of Magic numbers and updates its counter.
void CAccountProtector::ProcessMagicNumbers()
{
    magic_array_counter = 0;

    if (sets.MagicNumbers == "") return;

    // Split string with Magic numbers using all separators, getting an array with clean Magic numbers.
    string result[];
    int n = StringSplit(sets.MagicNumbers, StringGetCharacter(",", 0), result);
    for (int i = 0; i < n; i++)
    {
        string second_result[];
        int m = StringSplit(result[i], StringGetCharacter(";", 0), second_result);
        for (int j = 0; j < m; j++)
        {
            string third_result[];
            // Third result, at this point, holds all the magic numbers (strings) even if there was only one.
            // The problem is that it will vanish on next cycle iteration.
            int l = StringSplit(second_result[j], StringGetCharacter(" ", 0), third_result);

            // Fill MagicNumbers_array using magic_array_counter as an absolute counter.
            for (int k = 0; k < l; k++)
            {
                if (third_result[k] == "") continue;
                ArrayResize(MagicNumbers_array, magic_array_counter + 1, 10);
                MagicNumbers_array[magic_array_counter] = (int)StringToInteger(third_result[k]);
                magic_array_counter++;
            }
        }
    }
}

// Creates array of Magic numbers and updates its counter.
void CAccountProtector::ProcessInstruments()
{
    instruments_array_counter = 0;

    if (sets.Instruments == "") return;

    // Split string with Instruments using all separators, getting an array with clean Magic numbers.
    string result[];
    int n = StringSplit(sets.Instruments, StringGetCharacter(",", 0), result);
    for (int i = 0; i < n; i++)
    {
        string second_result[];
        int m = StringSplit(result[i], StringGetCharacter(";", 0), second_result);
        for (int j = 0; j < m; j++)
        {
            string third_result[];
            // Third result, at this point, holds all the Instruments (strings) even if there was only one.
            // The problem is that it will vanish on next cycle iteration.
            int l = StringSplit(second_result[j], StringGetCharacter(" ", 0), third_result);

            // Fill Instruments using instruments_array_counter as an absolute counter.
            for (int k = 0; k < l; k++)
            {
                if (third_result[k] == "") continue;
                ArrayResize(Instruments_array, instruments_array_counter + 1, 10);
                Instruments_array[instruments_array_counter] = third_result[k];
                StringToLower(Instruments_array[instruments_array_counter]);
                instruments_array_counter++;
            }
        }
    }
}

// Checks if value, entered into input field, is of double type.
bool CAccountProtector::IsDouble(const string value)
{
    int i, dot = 0;

    for (i = 0; i < StringLen(value); i++)
    {
        if ((i == 0) && (value[i] == '-')) continue; // Allow negative numbers.
        if (value[i] == '.') dot++;
        else if ((value[i] < '0') || (value[i] > '9')) return false;
    }
    if (dot > 1) return false;

    return true;
}

// Checks if value, entered into input field, is of integer type.
bool CAccountProtector::IsInteger(const string value)
{
    int i;

    for (i = 0; i < StringLen(value); i++)
    {
        if ((i == 0) && (value[i] == '-')) continue; // Allow negative numbers.
        if ((value[i] < '0') || (value[i] > '9'))  return false;
    }

    return true;
}

// Calculate order lots to close based on partial close percentage given.
double CAccountProtector::CalculateOrderLots(const double lots, const string symbol)
{
    if (sets.doubleClosePercentage == 100) return(lots);

    double vol_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double vol_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

    double volume = lots * sets.doubleClosePercentage / 100.0;

    if (volume < vol_min) return(vol_min);

    double steps = 0;
    if (vol_step != 0) steps = volume / vol_step;
    if (MathFloor(steps) < steps)
    {
        if (UseTotalVolume) volume = MathCeil(steps) * vol_step; // Close 0.02 out of 0.02 even with 70% partial close percentage if UseTotalVolume == true. Total volume closed will verify percentage compliance.
        else volume = MathFloor(steps) * vol_step; // Normal situation - close smallest part of the volume possible.
    }

    return(volume);
}
//+------------------------------------------------------------------+