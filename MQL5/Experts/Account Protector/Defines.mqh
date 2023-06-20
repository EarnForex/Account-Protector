//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                             Copyright © 2017-2023, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\Label.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\ComboBox.mqh>

#define CONTROLS_BUTTON_COLOR_ENABLE C'200,200,200'
#define CONTROLS_BUTTON_COLOR_DISABLE C'224,224,224'
#define CONTROLS_EDIT_COLOR_DISABLE C'221,221,211'

#define LOG_TIMER_VALUE_WRONG "Timer value is wrong. Time format: HH:MM."

enum TABS
{
    MainTab,
    FiltersTab,
    ConditionsTab,
    ActionsTab
};

enum Type_of_Order
{
    Pending,
    Active
};

enum Day_of_Week
{
    Any,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday
};

enum Position_Status
{
    All,
    Losing,
    Profitable
};

// Used as a class property to store the currently triggered condition.
// Checked for position array sorting (when optimal) and for partial position closure cancellation when UseTotalVolume is enabled.
// Filled on condition check.
enum ENUM_CONDITIONS
{
    Floating_loss_rises_to_perecentage,
    Floating_loss_rises_to_currency_units,
    Floating_loss_rises_to_points,
    Floating_profit_rises_to_perecentage,
    Floating_profit_rises_to_currency_units,
    Floating_profit_rises_to_points,
    Other_condition // Any other condition where sorting or partial closure is irrelevant.
};

enum ENUM_CLOSE_TRADES
{
    ENUM_CLOSE_TRADES_DEFAULT, // No order, as quickly as possible
    ENUM_CLOSE_TRADES_MOST_DISTANT_FIRST, // Most distant trades first
    ENUM_CLOSE_TRADES_NEAREST_FIRST, // Nearest trades first
    ENUM_CLOSE_TRADES_MOST_PROFITABLE_FIRST, // Most profitable trades first
    ENUM_CLOSE_TRADES_MOST_LOSING_FIRST // Most losing trades first
};

struct Settings
{
    bool             OnOff;
    bool             CountCommSwaps;
    bool             UseTimer;
    string           Timer;
    string           TimeLeft;
    int              intTimeType;
    datetime         dtTimerLastTriggerTime;
    bool             boolTrailingStart;
    int              intTrailingStart;
    bool             boolTrailingStep;
    int              intTrailingStep;
    bool             boolBreakEven;
    int              intBreakEven;
    double           doubleBreakEven;
    bool             boolBreakEvenExtra;
    int              intBreakEvenExtra;
    bool             boolEquityTrailingStop;
    double           doubleEquityTrailingStop;
    double           doubleCurrentEquityStopLoss;
    double           SnapEquity;
    string           SnapEquityTime;
    double           SnapMargin;
    string           SnapMarginTime;
    int              intOrderCommentaryCondition;
    string           OrderCommentary;
    int              intOrderDirection;
    string           MagicNumbers;
    bool             boolExcludeMagics;
    int              intInstrumentFilter;
    string           Instruments;
    bool             boolIgnoreLossTrades;
    bool             boolIgnoreProfitTrades;
    bool             boolLossPerBalance;
    bool             boolLossQuanUnits;
    bool             boolLossPoints;
    bool             boolProfPerBalance;
    bool             boolProfQuanUnits;
    bool             boolProfPoints;
    bool             boolLossPerBalanceReverse;
    bool             boolLossQuanUnitsReverse;
    bool             boolLossPointsReverse;
    bool             boolProfPerBalanceReverse;
    bool             boolProfQuanUnitsReverse;
    bool             boolProfPointsReverse;
    bool             boolEquityLessUnits;
    bool             boolEquityGrUnits;
    bool             boolEquityLessPerSnap;
    bool             boolEquityGrPerSnap;
    bool             boolEquityMinusSnapshot;
    bool             boolSnapshotMinusEquity;
    bool             boolMarginLessUnits;
    bool             boolMarginGrUnits;
    bool             boolMarginLessPerSnap;
    bool             boolMarginGrPerSnap;
    bool             boolPriceGE;
    bool             boolPriceLE;
    bool             boolMarginLevelGE;
    bool             boolMarginLevelLE;
    bool             boolSpreadGE;
    bool             boolSpreadLE;
    bool             boolDailyProfitLossUnitsGE;
    bool             boolDailyProfitLossUnitsLE;
    bool             boolDailyProfitLossPointsGE;
    bool             boolDailyProfitLossPointsLE;
    bool             boolDailyProfitLossPercGE;
    bool             boolDailyProfitLossPercLE;
    bool             boolNumberOfPositionsGE;
    bool             boolNumberOfOrdersGE;
    bool             boolNumberOfPositionsLE;
    bool             boolNumberOfOrdersLE;
    double           doubleLossPerBalance;
    double           doubleLossQuanUnits;
    int              intLossPoints;
    double           doubleProfPerBalance;
    double           doubleProfQuanUnits;
    int              intProfPoints;
    double           doubleLossPerBalanceReverse;
    double           doubleLossQuanUnitsReverse;
    int              intLossPointsReverse;
    double           doubleProfPerBalanceReverse;
    double           doubleProfQuanUnitsReverse;
    int              intProfPointsReverse;
    double           doubleEquityLessUnits;
    double           doubleEquityGrUnits;
    double           doubleEquityLessPerSnap;
    double           doubleEquityGrPerSnap;
    double           doubleEquityMinusSnapshot;
    double           doubleSnapshotMinusEquity;
    double           doubleMarginLessUnits;
    double           doubleMarginGrUnits;
    double           doubleMarginLessPerSnap;
    double           doubleMarginGrPerSnap;
    double           doublePriceGE;
    double           doublePriceLE;
    double           doubleMarginLevelGE;
    double           doubleMarginLevelLE;
    int              intSpreadGE;
    int              intSpreadLE;
    double           doubleDailyProfitLossUnitsGE;
    double           doubleDailyProfitLossUnitsLE;
    int              intDailyProfitLossPointsGE;
    int              intDailyProfitLossPointsLE;
    double           doubleDailyProfitLossPercGE;
    double           doubleDailyProfitLossPercLE;
    int              intNumberOfPositionsGE;
    int              intNumberOfOrdersGE;
    int              intNumberOfPositionsLE;
    int              intNumberOfOrdersLE;
    bool             ClosePos;
    double           doubleClosePercentage;
    Position_Status  CloseWhichPositions;
    bool             DeletePend;
    bool             DisAuto;
    bool             SendMails;
    bool             SendNotif;
    bool             ClosePlatform;
    bool             EnableAuto;
    bool             RecaptureSnapshots;
    bool             CloseAllOtherCharts;
    TABS             SelectedTab;
    bool             Triggered;
    string           TriggeredTime;
    Day_of_Week      TimerDayOfWeek;
} sets;
//+------------------------------------------------------------------+