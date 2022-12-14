#property copyright   "A. Zadrutskiy."
#property strict

enum TTPMode
{
Type_Fixed=0,
Type_None=2
};
enum TMMMode
{
MM_Fixed=0,
MM_RistPr=1,
MM_Amount001=2
};
enum TMAMode
{
MA_SMA=0,
MA_EMA=1,
MA_SMMA=2,
MA_LWMA=3
};
enum TMATypeSelect
{
MA_Standart=0,
MA_UMA=1
};

input string Div1="*** MoneyManagement Settings ***";
//True - AutoMode. it works only if you use SL and calculate Lot size using % of deposit and SL.  If UseMM=false it is manual mode. Fixed lot size will be used.
extern TMMMode UseMM=0;
//For Manual mode
input double FixedLot=0.1;
//For Auto mode
input double RiskPr=2;
input double Amount001=200;
input double MaxLot=100;
input int MaxAttempts=1;
input int AttemptPauseSec=60;
input string Div3="*** 2MA 1 ***";
input ENUM_TIMEFRAMES MATimeframe=PERIOD_CURRENT;
input int MA_MA1Period=10;
input ENUM_MA_METHOD MA_MA1Type=1;
input ENUM_APPLIED_PRICE MA_MA1Price=0;
input int MA_MA1Shift=1;
input double MA_MA1K=100;
input int MA_MA2Period=20;
input ENUM_MA_METHOD MA_MA2Type=1;
input ENUM_APPLIED_PRICE MA_MA2Price=0;
input int MA_MA2Shift=1;
input double MA_MA2K=100;
input int TrendChangeMeasureOpen1=10;
input int TrendChangeMeasureClose1=10;
input string Div4="*** 2MA 2 ***";
input ENUM_TIMEFRAMES MA2Timeframe=PERIOD_CURRENT;
input int MA2_MA1Period=10;
input ENUM_MA_METHOD MA2_MA1Type=1;
input ENUM_APPLIED_PRICE MA2_MA1Price=0;
input int MA2_MA1Shift=1;
input double MA2_MA1K=100;
input int MA2_MA2Period=20;
input ENUM_MA_METHOD MA2_MA2Type=1;
input ENUM_APPLIED_PRICE MA2_MA2Price=0;
input int MA2_MA2Shift=1;
input double MA2_MA2K=100;
input int TrendChangeMeasureOpen2=10;
input int TrendChangeMeasureClose2=10;
input int TrendChangeMeasureMaxLen=100;

input string Div5="*** Trade Settings ***";
input bool TradeAverageChangeTrend1=true;
input bool TradeAverageChangeTrend2=true;
input bool TradeCloseAverageChangeTrend1=true;
input bool TradeCloseAverageChangeTrend2=true;


input string Div6="*** Take Profit Settings ***";
//Type_None - no TP, Type_Fixed - TP in points, Type_PrAdr - TP in % of ATR
input TTPMode TPMode = 2;
//Points or ATR depanding from chousen type
input double TakeProfit=100;
input string Div7="*** Stop Loss Settings ***";
//Type_None - no SL, Type_Fixed - SL in points, Type_PrAdr - SL in % of ATR
input TTPMode SLMode = 2;
//Points or ATR depanding from chousen type
input double StopLoss=100;





extern string Div8="*** Martingale ***";
extern bool Martingale=true;
extern double LotMultiplier=1.5;
extern int MinDistBetweenMartOrd=50;
extern bool SameMartSLTP=1;
extern int MartTakeProfit=20;
extern int MartTrailSize=0;
//extern int MartTrailStart=0;
extern int MaxMartingaile=1;
extern bool MartingaileAfterStopTime=1;
//extern bool RSILimitCrossRule=0;

input string Div9="*** Breakeven ***";
//On/Off
extern bool BEActive=0;
//% of TP there BE will move SL
input double BrkEvnStpPoint=50;
//SL position, additional points
input int BrkEvnPlPips=5;
input string Div10="***Trailing1 ***";
//On/Off
extern bool Trail1_Active=0;
extern bool Trail1_MaxProfit=true;
//How often it shift, dont change it. It will work well with 1point
input int Trail1_MinStepPoint=1;
//Minimum profit in points
input int Trail1_Start=1;
//Trailing size
input int Trail1=50;
input int MaxTrail1=50;
input string Div11="***Trailing2 ***";
//On/Off
extern bool Trail2_Active=0;
extern bool Trail2_MaxProfit=true;
//How often it shift, dont change it. It will work well with 1point
input int Trail2_MinStepPoint=1;
//Minimum profit in points
input int Trail2_Start=1;
//Trailing size
input int Trail2=100;
input int MaxTrail2=200;
input string Div12="***Trailing3 ***";
//On/Off
extern bool Trail3_Active=0;
extern bool Trail3_MaxProfit=true;
//How often it shift, dont change it. It will work well with 1point
input int Trail3_MinStepPoint=1;
//Minimum profit in points
input int Trail3_Start=1;
//Trailing size
input int Trail3=100;
input int MaxTrail3=200;

input string Div13="***Allert Settings ***";
input bool ShowAllert=1;
input bool SendEMail=0;
input bool ShowBuySellArrow=1;
input int BuySellArrowSize=2;
input color SellArrowColor=clrRed;
input color BuyArrowColor=clrLime;
extern string Div25="===Daily Session======";
extern bool Trade_Daily_Session_Times_only=1;
extern int Trade_Hour_Start=0;
extern int Trade_Minute_Start=0;
extern int Trade_Hour_Stop=24;
extern int Trade_Minute_Stop=0;


extern bool Close_EndOfDay=1;
extern int Close_EndOfDay_Hour=24;
extern int Close_EndOfDay_Minute=0;

extern bool Close_EndOfWeek=1;
extern int Close_EndOfWeek_Hour=24;
extern int Close_EndOfWeek_Minute=0;



extern bool Trade_Daily_Selected_Candles_only=0;
extern int Trade_Candle_Start=0;
extern int Trade_Candle_Stop=1440;


input int MaxTradesBuy=1;
input int MaxTradesSell=1;
input int MaxTradesADay=1;
input int MaxSpread=50;//If spread more it will not trade
input int MagicNumber=123456;


datetime LastSellTime,LastBuyTime;
double MinBuyLot=0, MaxSellLot=0,MaxBuyLot=0, MinSellLot=0;
double MedPriceSell, MedPriceBuy;

bool BuyOpen_1=0,SellOpen_1=0;
int AmountAttemptsBuy=0,AmountAttemptsSell=0;
datetime LastAttemptTimeBuy=0,LastAttemptTimeSell=0;
bool BuyOpen_Last=0,SellOpenLast=0;
double BuyOpenMeasure2=0, SellOpenMeasure2=0;
double BuyOpenMeasure1=0, SellOpenMeasure1=0;
double BuyOpenMeasure1_1=0, SellOpenMeasure1_1=0;
double BuyOpenMeasure2_1=0, SellOpenMeasure2_1=0;
datetime TrendchMeasureLastTime=0;
double MA1=0;
double MA1_1=0;
double MA2=0;
double MA2_1=0;
/*
double MACD=0;
double MACD_1=0;
double MACDS=0;
double MACDS_1=0;
*/

double HighestMA1=0,LowestMA1=0,HighestMA2=0,LowestMA2=0;
int LotsDigitsAfterPoint;
bool CloseEndOfDay=0,CloseEndOfWeek=0,CloseALLTime=0;


bool DailySessionTimeFilter()
   {
   if(Trade_Daily_Session_Times_only)
      {
      if(((TimeHour(TimeCurrent())>Trade_Hour_Start) || (TimeHour(TimeCurrent())==Trade_Hour_Start && TimeMinute(TimeCurrent())>=Trade_Minute_Start))&&
      ((TimeHour(TimeCurrent())<Trade_Hour_Stop) || (TimeHour(TimeCurrent())==Trade_Hour_Stop && TimeMinute(TimeCurrent())<=Trade_Minute_Stop)))return true;
      return false;
      }
   else
      {
      return true;
      }
      return false;
   }
   
bool DailyCandlesTimeFilter()
   {
   if(Trade_Daily_Selected_Candles_only)
      {
      if(TimeCurrent()-iTime(Symbol(),PERIOD_D1,0)>=Trade_Candle_Start*Period()*60&&TimeCurrent()-iTime(Symbol(),PERIOD_D1,0)<=(Trade_Candle_Stop)*Period()*60)return true;
      return false;
      }
   else
      {
      return true;
      }
      return false;
   }




double GetTradeSizePr(double SL,double RiskPr1,string PairName,double FixLot)
{
if(UseMM==MM_RistPr)
   {
   if(SL<=0)return  AccountInfoDouble(ACCOUNT_BALANCE)*RiskPr1/100/1/MarketInfo(PairName,MODE_TICKVALUE)*MarketInfo(PairName,MODE_TICKSIZE)/MarketInfo(PairName,MODE_POINT);
   else return  AccountInfoDouble(ACCOUNT_BALANCE)*RiskPr1/100/SL/MarketInfo(PairName,MODE_TICKVALUE)*MarketInfo(PairName,MODE_TICKSIZE)/MarketInfo(PairName,MODE_POINT);
   }
else if(UseMM==MM_Fixed)
   {
   return  FixLot;
   }
else if(UseMM==MM_Amount001)
   {
   double Lot=(AccountInfoDouble(ACCOUNT_BALANCE)-Amount001/2)/Amount001*0.01;
   if(Lot<0.01)Lot=0.01;
   return  Lot;
   }
return FixLot;
}  

datetime StringToTime1(string TimeString)
   {
   int Hour1=StringToInteger(StringSubstr(TimeString,0,2));
   int Min1=StringToInteger(StringSubstr(TimeString,3,2));
   datetime TimeCur=TimeCurrent();
   datetime TimeRes=TimeCur-TimeHour(TimeCur)*60*60-TimeMinute(TimeCur)*60+Hour1*60*60+Min1*60;
   return TimeRes;
   }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   LastBuyTime=0;
   LastSellTime=0;
   if(SLMode==Type_None)
      {
      UseMM=0;
      Print("Money management switched off, becouse no SL selected");
      }
   TrendchMeasureLastTime=0;
      
   bool DirChUp1=0;
   bool DirChDn1=0;
   bool DirChUp2=0;
   bool DirChDn2=0;
      double MA1_0x=0;
      double MA1_1x=0;
      double MA2_0x=0;
      double MA2_1x=0;

   for(int i=1;i<MA_MA1Period+MA_MA2Period+MA2_MA1Period+MA2_MA2Period && i<Bars;i++)
      {
      
      MA1_0x=iCustom(Symbol(),MATimeframe,"2MAs",MA_MA1Period,MA_MA1Type,MA_MA1Price,MA_MA1Shift,MA_MA1K,MA_MA2Period,MA_MA2Type,MA_MA2Price,MA_MA2Shift,MA_MA2K,0,i);
      MA1_1x=iCustom(Symbol(),MATimeframe,"2MAs",MA_MA1Period,MA_MA1Type,MA_MA1Price,MA_MA1Shift,MA_MA1K,MA_MA2Period,MA_MA2Type,MA_MA2Price,MA_MA2Shift,MA_MA2K,0,i+1);
      MA2_0x=iCustom(Symbol(),MA2Timeframe,"2MAs",MA2_MA1Period,MA2_MA1Type,MA2_MA1Price,MA2_MA1Shift,MA2_MA1K,MA2_MA2Period,MA2_MA2Type,MA2_MA2Price,MA2_MA2Shift,MA2_MA2K,0,i);
      MA2_1x=iCustom(Symbol(),MA2Timeframe,"2MAs",MA2_MA1Period,MA2_MA1Type,MA2_MA1Price,MA2_MA1Shift,MA2_MA1K,MA2_MA2Period,MA2_MA2Type,MA2_MA2Price,MA2_MA2Shift,MA2_MA2K,0,i+1);
      if(i==1)
         {
         HighestMA1=MA1_0x;
         LowestMA1=MA1_0x;
         HighestMA2=MA2_0x;
         LowestMA2=MA2_0x;
         }


      if(MA1_0x>MA1_1x)DirChUp1=1;
      if(MA1_0x<MA1_1x)DirChDn1=1;
      if(MA2_0x>MA2_1x)DirChUp2=1;
      if(MA2_0x<MA2_1x)DirChDn2=1;
      
      if(MA1_0x>MA1_1x && !DirChDn1 && MA1_1x<LowestMA1){LowestMA1=MA1_1x;}
      if(MA1_0x<MA1_1x && !DirChUp1 && MA1_1x>HighestMA1){HighestMA1=MA1_1x;}
      
      if(MA2_0x>MA2_1x && !DirChDn2 && MA2_1x<LowestMA2){LowestMA2=MA2_1x;}
      if(MA2_0x<MA2_1x && !DirChUp2 && MA2_1x>HighestMA2){HighestMA2=MA2_1x;}
      }
      
  LotsDigitsAfterPoint=log10(1.0/MarketInfo(Symbol(),MODE_LOTSTEP));
  if(LotsDigitsAfterPoint<1)LotsDigitsAfterPoint=0;else if(LotsDigitsAfterPoint<2)LotsDigitsAfterPoint=1;else if(LotsDigitsAfterPoint<3)LotsDigitsAfterPoint=2;
      
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  


   int TradesThisDay=0;


   if(TrendchMeasureLastTime<Time[0])
   {
   TrendchMeasureLastTime=TimeCurrent();
   MA1=0;
   MA1_1=0;
   MA2=0;
   MA2_1=0;
   MA1=iCustom(Symbol(),MATimeframe,"2MAs",MA_MA1Period,MA_MA1Type,MA_MA1Price,MA_MA1Shift,MA_MA1K,MA_MA2Period,MA_MA2Type,MA_MA2Price,MA_MA2Shift,MA_MA2K,0,1);
   MA1_1=iCustom(Symbol(),MATimeframe,"2MAs",MA_MA1Period,MA_MA1Type,MA_MA1Price,MA_MA1Shift,MA_MA1K,MA_MA2Period,MA_MA2Type,MA_MA2Price,MA_MA2Shift,MA_MA2K,0,2);
   MA2=iCustom(Symbol(),MA2Timeframe,"2MAs",MA2_MA1Period,MA2_MA1Type,MA2_MA1Price,MA2_MA1Shift,MA2_MA1K,MA2_MA2Period,MA2_MA2Type,MA2_MA2Price,MA2_MA2Shift,MA2_MA2K,0,1);
   MA2_1=iCustom(Symbol(),MA2Timeframe,"2MAs",MA2_MA1Period,MA2_MA1Type,MA2_MA1Price,MA2_MA1Shift,MA2_MA1K,MA2_MA2Period,MA2_MA2Type,MA2_MA2Price,MA2_MA2Shift,MA2_MA2K,0,2);

   if(MA1>MA1_1)HighestMA1=MA1;
   if(MA1<MA1_1)LowestMA1=MA1;
   if(MA2>MA2_1)HighestMA2=MA2;
   if(MA2<MA2_1)LowestMA2=MA2;

   BuyOpenMeasure1=(MA1!=EMPTY_VALUE && LowestMA1!=EMPTY_VALUE)?MA1-LowestMA1:0;
   BuyOpenMeasure2=(MA2!=EMPTY_VALUE && LowestMA2!=EMPTY_VALUE)?MA2-LowestMA2:0;
   SellOpenMeasure1=(MA1!=EMPTY_VALUE && HighestMA1!=EMPTY_VALUE)?HighestMA1-MA1:0;
   SellOpenMeasure2=(MA2!=EMPTY_VALUE && HighestMA2!=EMPTY_VALUE)?HighestMA2-MA2:0;

   TradesThisDay=0;
   //datetime LastTime=0;
   for(int j=OrdersHistoryTotal();j>=0;j--)
      {
      OrderSelect(j, SELECT_BY_POS, MODE_HISTORY);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
         //if(OrderCloseTime()>LastTime){LastTime=OrderCloseTime();LastTicket=OrderTicket();}
         if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()))TradesThisDay++;
         }
      }
   int totaln=OrdersTotal();
   for(int j=0;j<totaln;j++)
      {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()))TradesThisDay++;
         }
      }
   
   CloseEndOfDay=Close_EndOfDay && (TimeHour(TimeCurrent())>Close_EndOfDay_Hour || (TimeHour(TimeCurrent())==Close_EndOfDay_Hour && TimeMinute(TimeCurrent())>=Close_EndOfDay_Minute));
   CloseEndOfWeek=Close_EndOfWeek && TimeDayOfWeek(TimeCurrent())==5 && (TimeHour(TimeCurrent())>Close_EndOfWeek_Hour || (TimeHour(TimeCurrent())==Close_EndOfWeek_Hour && TimeMinute(TimeCurrent())>=Close_EndOfWeek_Minute));
   CloseALLTime=CloseEndOfDay || CloseEndOfWeek;

   
   }

   //Print(BuyOpenMeasure1," ",BuyOpenMeasure2," ",SellOpenMeasure1," ",SellOpenMeasure2," ",MA1," ",MA1_1," ",MA2," ",MA2_1," ",HighestMA1," ",LowestMA1," ",HighestMA2," ",LowestMA2);

   //int LastTicket=-1;


//bool UpRSICross=RSI_1>RSI_TopLimit && RSI_2<=RSI_TopLimit;

//bool DnRsiCross=RSI_1<RSI_BottomLimit && RSI_2>=RSI_BottomLimit;

  double LowestBuy=1000000;
  double HighestSell=0;
  double LowestSell=1000000;
  double HighestBuy=0;
  int LowestSellTick=-1;
  int HighestBuyTick=-1;
  double LotsSell=0,LotsBuy=0;
  double SummPriceSell=0,SummPriceBuy=0;
  double BuySummPriceVol=0,BuySummLots=0;
  double SellSummPriceVol=0,SellSummLots=0;
  int totaln=OrdersTotal();
  int total=0;
  int totalBuy=0,totalSell=0;
  bool AllBuyProfit=1, AllSellProfit=1;
  double VolBuy=0,VolSell=0;
  MinBuyLot=0;
  MaxSellLot=0;
  MinSellLot=0;
  MaxBuyLot=0;
   
   double ProfitSumm=0;
   
   for(int j=0;j<totaln;j++)
      {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         total=total+1;
         }
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(OrderOpenPrice()>HighestSell){HighestSell=OrderOpenPrice();MaxSellLot=OrderLots();}
         if(OrderOpenPrice()<LowestSell){LowestSell=OrderOpenPrice();LowestSellTick=OrderTicket();MinSellLot=OrderLots();}
         totalSell=totalSell+1;
         SellSummPriceVol+=OrderOpenPrice()*OrderLots();
         SellSummLots+=OrderLots();
         if(OrderProfit()<0)AllSellProfit=0;
         ProfitSumm+=OrderProfit();
         VolSell+=OrderLots();
         }
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(OrderOpenPrice()<LowestBuy){LowestBuy=OrderOpenPrice();MinBuyLot=OrderLots();}
         if(OrderOpenPrice()>HighestBuy){HighestBuy=OrderOpenPrice();HighestBuyTick=OrderTicket();MaxBuyLot=OrderLots();}
         totalBuy=totalBuy+1;
         BuySummPriceVol+=OrderOpenPrice()*OrderLots();
         BuySummLots+=OrderLots();
         if(OrderProfit()<0)AllBuyProfit=0;
         ProfitSumm+=OrderProfit();
         VolBuy+=OrderLots();
         }
      }
   MedPriceSell=(SellSummLots>0)?SellSummPriceVol/SellSummLots:0;
   MedPriceBuy=(BuySummLots>0)?BuySummPriceVol/BuySummLots:0;
   double MartBuyTP=(MartTakeProfit>0)?MedPriceBuy+MartTakeProfit*Point():0;
   double MartSellTP=(MartTakeProfit>0)?MedPriceSell-MartTakeProfit*Point():0;
   //double MartTrailStartBuy=MedPriceBuy+MartTrailStart*Point();
   //double MartTrailStartSell=MedPriceSell-MartTrailStart*Point();
   double MartTrailPosBuy=Bid-MartTrailSize*Point();
   double MartTrailPosSell=Ask+MartTrailSize*Point();
   

   
   if(HighestBuyTick>-1)OrderSelect(HighestBuyTick, SELECT_BY_TICKET);
   double MartBuySL=OrderStopLoss();
   if(LowestSellTick>-1)OrderSelect(LowestSellTick, SELECT_BY_TICKET);
   double MartSellSL=OrderStopLoss();
  MartBuyTP=NormalizeDouble(MartBuyTP,Digits);
  MartBuySL=NormalizeDouble(MartBuySL,Digits);
  MartSellTP=NormalizeDouble(MartSellTP,Digits);
  MartSellSL=NormalizeDouble(MartSellSL,Digits);
  //MartTrailStartBuy=NormalizeDouble(MartTrailStartBuy,Digits);
  //MartTrailStartSell=NormalizeDouble(MartTrailStartSell,Digits);
  MartTrailPosBuy=NormalizeDouble(MartTrailPosBuy,Digits);
  MartTrailPosSell=NormalizeDouble(MartTrailPosSell,Digits);
  
  bool BuyDistanceControl=LowestBuy<1000000 && Ask<LowestBuy-MinDistBetweenMartOrd*Point() && Martingale;// && (!RSILimitCrossRule || DnRsiCross);
  bool SellDistanceControl=HighestSell>0 && Bid>HighestSell+MinDistBetweenMartOrd*Point() && Martingale;// && (!RSILimitCrossRule || UpRSICross);
   double MartLotBuy=NormalizeDouble(VolBuy*LotMultiplier,LotsDigitsAfterPoint);
   if(MartLotBuy>MaxLot)MartLotBuy=MaxLot;
   double MartLotSell=NormalizeDouble(VolSell*LotMultiplier,LotsDigitsAfterPoint);
   if(MartLotSell>MaxLot)MartLotSell=MaxLot;
//if(totalBuy>0)Print("jk ",LowestBuy);
  

  
  
  
  
  
//---
  double TP=0;
  double SL=0;
  


   int shift=1;
   
   bool BuyOpen=
   ((BuyOpenMeasure1>TrendChangeMeasureOpen1*Point() && BuyOpenMeasure1_1<=TrendChangeMeasureOpen1*Point() && TradeAverageChangeTrend1) || 
   (BuyOpenMeasure2>TrendChangeMeasureOpen2*Point() && BuyOpenMeasure2_1<=TrendChangeMeasureOpen2*Point() && TradeAverageChangeTrend2))
   && BuyOpenMeasure2>TrendChangeMeasureOpen2*Point() && BuyOpenMeasure1>TrendChangeMeasureOpen1*Point();
   
   bool SellOpen=
   ((SellOpenMeasure1>TrendChangeMeasureOpen1*Point() && SellOpenMeasure1_1<=TrendChangeMeasureOpen1*Point() && TradeAverageChangeTrend1) || 
   (SellOpenMeasure2>TrendChangeMeasureOpen2*Point() && SellOpenMeasure2_1<=TrendChangeMeasureOpen2*Point() && TradeAverageChangeTrend2))
   && SellOpenMeasure2>TrendChangeMeasureOpen2*Point() && SellOpenMeasure1>TrendChangeMeasureOpen1*Point();
   
   bool BuyClose=(SellOpenMeasure1>TrendChangeMeasureOpen1*Point() && TradeCloseAverageChangeTrend1) || (SellOpenMeasure2>TrendChangeMeasureOpen2*Point() && TradeCloseAverageChangeTrend2);
   bool SellClose=(BuyOpenMeasure1>TrendChangeMeasureOpen1*Point() && TradeCloseAverageChangeTrend1) || (BuyOpenMeasure2>TrendChangeMeasureOpen2*Point() && TradeCloseAverageChangeTrend2);

   BuyOpenMeasure1_1=BuyOpenMeasure1;
   SellOpenMeasure1_1=SellOpenMeasure1;
   BuyOpenMeasure2_1=BuyOpenMeasure2;
   SellOpenMeasure2_1=SellOpenMeasure2;

   if(!BuyOpen){AmountAttemptsBuy=0;LastAttemptTimeBuy=0;}
   if(!SellOpen){AmountAttemptsSell=0;LastAttemptTimeSell=0;}

   BuyOpen_Last=BuyOpen;
   SellOpenLast=SellOpen;
 
   bool BuyOpenPauseNumOk=TimeCurrent()-LastAttemptTimeBuy>AttemptPauseSec && AmountAttemptsBuy<MaxAttempts;
   bool SellOpenPauseNumOk=TimeCurrent()-LastAttemptTimeSell>AttemptPauseSec && AmountAttemptsSell<MaxAttempts;



      if(totalSell<MaxTradesSell&&TradesThisDay<MaxTradesADay&&DailySessionTimeFilter()&&DailyCandlesTimeFilter() && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek && SellOpenPauseNumOk && SellOpen && (Time[0]>LastSellTime) && MarketInfo(Symbol(),MODE_SPREAD)<=MaxSpread)// && totalSell<MaxTradesSell
            {
            LastSellTime=TimeCurrent();
            TP=(TPMode==Type_Fixed)?Bid-TakeProfit*Point():(0);
            SL=(SLMode==Type_Fixed)?Bid+StopLoss*Point():(0);
            //Print(
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            double OrderLots1=GetTradeSizePr((SL-Bid)/Point(),RiskPr,Symbol(),FixedLot);
            if(OrderLots1>MaxLot)OrderLots1=MaxLot;
            OrderLots1=NormalizeDouble(OrderLots1,LotsDigitsAfterPoint);
            int ticket=OrderSend(Symbol(),OP_SELL,OrderLots1,Bid,30,SL,TP,"",MagicNumber,0,Green);//GetTradeSize(LostCount[TimePeriodNum])
            if(ticket!=-1)
               {
               Print("Expert Report : OrderSent ",ticket," ",Symbol()," Lots : ",OrderLots1," OP_SELL");
               if(ShowAllert)Alert("Sell order sent. LotSize=",DoubleToStr(OrderLots1,LotsDigitsAfterPoint));
               if(SendEMail)SendMail("Expert report","Sell order sent. "+Symbol()+" LotSize="+DoubleToStr(OrderLots1,LotsDigitsAfterPoint));
               if(ShowBuySellArrow)
                  {
                  long EmptyVar;
                  string ArrowName="Arrow_"+TimeToStr(TimeCurrent(),TIME_DATE)+TimeToStr(TimeCurrent(),TIME_MINUTES);
                  if(ObjectGetInteger(ChartID(),ArrowName,OBJPROP_WIDTH,0,EmptyVar))ObjectDelete(ArrowName);
                  double HH1=High[iHighest(Symbol(),0,MODE_HIGH,5,0)];
                  CheckAndCreateArrowDown(ArrowName,TimeCurrent(),HH1+1*Point(),BuySellArrowSize,SellArrowColor,0);
                  }
               }
            else 
               {
               Print("Expert Report : OrderSend Error. Error=",ErrorDesc(GetLastError())," OrderData : ",Symbol()," Lots : ",OrderLots1," OP_SELL"," Price: ",Bid," SL : ",SL," TP : ",TP);
               
               }
            }
      if(totalSell<MaxTradesSell&&TradesThisDay<MaxTradesADay&&DailySessionTimeFilter()&&DailyCandlesTimeFilter() && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek && SellOpenPauseNumOk && SellOpen && (Time[0]>LastSellTime))// && totalSell<MaxTradesSell
            {
            LastAttemptTimeSell=TimeCurrent();
            AmountAttemptsSell++;
            }
      if(totalBuy<MaxTradesBuy&&TradesThisDay<MaxTradesADay&&DailySessionTimeFilter()&&DailyCandlesTimeFilter() && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek && BuyOpenPauseNumOk && BuyOpen && (Time[0]>LastBuyTime) && MarketInfo(Symbol(),MODE_SPREAD)<=MaxSpread)// && totalBuy<MaxTradesBuy
            {
            LastBuyTime=TimeCurrent();
            TP=(TPMode==Type_Fixed)?Ask+TakeProfit*Point():(0);
            SL=(SLMode==Type_Fixed)?Ask-StopLoss*Point():(0);
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            double OrderLots1=GetTradeSizePr((Bid-SL)/Point(),RiskPr,Symbol(),FixedLot);
            if(OrderLots1>MaxLot)OrderLots1=MaxLot;
            OrderLots1=NormalizeDouble(OrderLots1,LotsDigitsAfterPoint);
            int ticket=OrderSend(Symbol(),OP_BUY,OrderLots1,Ask,30,SL,TP,"",MagicNumber,0,Green);//GetTradeSize(LostCount[TimePeriodNum])
            if(ticket!=-1)
               {
               Print("Expert Report : OrderSent ",ticket," ",Symbol()," Lots : ",OrderLots1," OP_BUY");
               if(ShowAllert)Alert("Buy order sent. LotSize=",DoubleToStr(OrderLots1,LotsDigitsAfterPoint));
               if(SendEMail)SendMail("Expert report","Buy order sent. "+Symbol()+" LotSize="+DoubleToStr(OrderLots1,LotsDigitsAfterPoint));
               if(ShowBuySellArrow)
                  {
                  long EmptyVar;
                  string ArrowName="ArrowTT_"+TimeToStr(TimeCurrent(),TIME_DATE)+TimeToStr(TimeCurrent(),TIME_MINUTES);
                  if(ObjectGetInteger(ChartID(),ArrowName,OBJPROP_WIDTH,0,EmptyVar))ObjectDelete(ArrowName);
                  double LL1=Low[iLowest(Symbol(),0,MODE_LOW,5,0)];
                  CheckAndCreateArrowUp(ArrowName,TimeCurrent(),LL1-1*Point(),BuySellArrowSize,BuyArrowColor,0);
                  }
               }
            else Print("Expert Report : OrderSend Error. Error : ",ErrorDesc(GetLastError())," OrderData : ",Symbol()," Lots : ",OrderLots1," OP_BUY"," Price: ",Bid," SL : ",SL," TP : ",TP);
            }
      if(totalBuy<MaxTradesBuy&&TradesThisDay<MaxTradesADay&&DailySessionTimeFilter()&&DailyCandlesTimeFilter() && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek && BuyOpenPauseNumOk && BuyOpen && (Time[0]>LastBuyTime))// && totalBuy<MaxTradesBuy
            {
            LastAttemptTimeBuy=TimeCurrent();
            AmountAttemptsBuy++;
            }
   //OrderClose
   if(BuyClose || SellClose || CloseALLTime)
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if(OrderType()<=OP_SELL && Symbol()==OrderSymbol() && OrderMagicNumber()==MagicNumber) 
         {
       //  Print("MDFX");
         if(OrderType()==OP_BUY && (BuyClose ||  CloseALLTime))// && CloseOnOppositeSignal)
            {
            if(BuyClose)
               {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,30,clrNONE))Print("Order close error :",ErrorDesc(GetLastError()));
               if(ShowAllert)Alert("Sell order closed by opposite signal.");
               if(SendEMail)SendMail("Expert report",Symbol()+"Buy order Closed by opposite signal.");
               }
            else
               {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,30,clrNONE))Print("Order close error :",ErrorDesc(GetLastError()));
               if(ShowAllert)Alert("Sell order closed by EndTime.");
               if(SendEMail)SendMail("Expert report",Symbol()+"Buy order Closed by EndTime.");
               }
            }
         if(OrderType()==OP_SELL && (SellClose ||  CloseALLTime))// && CloseOnOppositeSignal)
            {
            if(SellClose)
               {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,30,clrNONE))Print("Order close error :",ErrorDesc(GetLastError()));
               if(ShowAllert)Alert("Sell order closed by opposite signal.");
               if(SendEMail)SendMail("Expert report",Symbol()+"Sell order Closed by opposite signal.");
               }
            else
               {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,30,clrNONE))Print("Order close error :",ErrorDesc(GetLastError()));
               if(ShowAllert)Alert("Sell order closed by EndTime.");
               if(SendEMail)SendMail("Expert report",Symbol()+"Sell order Closed by EndTime.");
               }
            }
         }
      }
      
   if(totalSell>0)
      if(Time[0]>LastSellTime && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek &&/* SellOpenPauseNumOk && */totalSell<=MaxMartingaile && (((!(DailySessionTimeFilter()&&DailyCandlesTimeFilter()))&&MartingaileAfterStopTime) || ((!MartingaileAfterStopTime)&&(DailySessionTimeFilter()&&DailyCandlesTimeFilter()))) && SellDistanceControl && MarketInfo(Symbol(),MODE_SPREAD)<=MaxSpread)// && (Time[0]>LastSellTime) && totalSell<MaxTradesSell
            {
            LastSellTime=TimeCurrent();
            int ticket=OrderSend(Symbol(),OP_SELL,MartLotSell,Bid,30,MartSellSL,MartSellTP,"",MagicNumber,0,Green);//GetTradeSize(LostCount[TimePeriodNum])
            if(ticket!=-1)
               {
               Print("Expert Report : OrderSent ",ticket," ",Symbol()," Lots : ",MartLotSell," OP_SELL");
               if(ShowAllert)Alert("Sell order sent. LotSize=",DoubleToStr(MartLotSell,LotsDigitsAfterPoint));
               if(SendEMail)SendMail("Expert report","Sell order sent. "+Symbol()+" LotSize="+DoubleToStr(MartLotSell,LotsDigitsAfterPoint));
               if(ShowBuySellArrow)
                  {
                  long EmptyVar;
                  string ArrowName="Arrow_"+TimeToStr(TimeCurrent(),TIME_DATE)+TimeToStr(TimeCurrent(),TIME_MINUTES);
                  if(ObjectGetInteger(ChartID(),ArrowName,OBJPROP_WIDTH,0,EmptyVar))ObjectDelete(ArrowName);
                  double HH1=High[iHighest(Symbol(),0,MODE_HIGH,5,0)];
                  CheckAndCreateArrowDown(ArrowName,TimeCurrent(),HH1+1*Point(),BuySellArrowSize,SellArrowColor,0);
                  }
               }
            else Print("Expert Report : OrderSend Error. Error=",ErrorDesc(GetLastError())," OrderData : ",Symbol()," Lots : ",MartLotSell," OP_SELL"," Price: ",Bid," SL : ",MartSellSL," TP : ",MartSellTP);
            }
                  
   if(totalBuy>0)  
      if(Time[0]>LastSellTime && !CloseALLTime && !CloseEndOfDay && !CloseEndOfWeek && totalBuy<=MaxMartingaile/* && BuyOpenPauseNumOk*/ && ((MartingaileAfterStopTime&&(!(DailySessionTimeFilter()&&DailyCandlesTimeFilter()))) || ((!MartingaileAfterStopTime)&&(DailySessionTimeFilter()&&DailyCandlesTimeFilter()))) && BuyDistanceControl && MarketInfo(Symbol(),MODE_SPREAD)<=MaxSpread)// && (Time[0]>LastBuyTime) && totalBuy<MaxTradesBuy
            {
            LastBuyTime=TimeCurrent();
            int ticket=OrderSend(Symbol(),OP_BUY,MartLotBuy,Ask,30,MartBuySL,MartBuyTP,"",MagicNumber,0,Green);//GetTradeSize(LostCount[TimePeriodNum])
            if(ticket!=-1)
               {
               Print("Expert Report : OrderSent ",ticket," ",Symbol()," Lots : ",MartLotBuy," OP_BUY");
               if(ShowAllert)Alert("Buy order sent. LotSize=",DoubleToStr(MartLotBuy,LotsDigitsAfterPoint));
               if(SendEMail)SendMail("Expert report","Buy order sent. "+Symbol()+" LotSize="+DoubleToStr(MartLotBuy,LotsDigitsAfterPoint));
               if(ShowBuySellArrow)
                  {
                  long EmptyVar;
                  string ArrowName="ArrowTT_"+TimeToStr(TimeCurrent(),TIME_DATE)+TimeToStr(TimeCurrent(),TIME_MINUTES);
                  if(ObjectGetInteger(ChartID(),ArrowName,OBJPROP_WIDTH,0,EmptyVar))ObjectDelete(ArrowName);
                  double LL1=Low[iLowest(Symbol(),0,MODE_LOW,5,0)];
                  CheckAndCreateArrowUp(ArrowName,TimeCurrent(),LL1-1*Point(),BuySellArrowSize,BuyArrowColor,0);
                  }
               }
            else Print("Expert Report : OrderSend Error. Error : ",ErrorDesc(GetLastError())," OrderData : ",Symbol()," Lots : ",MartLotBuy," OP_BUY"," Price: ",Bid," SL : ",MartBuySL," TP : ",MartBuyTP);
            }
   
  LowestBuy=1000000;
  HighestSell=0;
  LowestSell=1000000;
  HighestBuy=0;
  LowestSellTick=-1;
  HighestBuyTick=-1;
  LotsSell=0;
  LotsBuy=0;
  SummPriceSell=0;SummPriceBuy=0;
  BuySummPriceVol=0;BuySummLots=0;
  SellSummPriceVol=0;SellSummLots=0;
  totaln=OrdersTotal();
  total=0;
  totalBuy=0;totalSell=0;
  AllBuyProfit=1;AllSellProfit=1;
   MinBuyLot=0;
   MaxSellLot=0;
   MinSellLot=0;
   MaxBuyLot=0;
   for(int j=0;j<totaln;j++)
      {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) total=total+1;
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(OrderOpenPrice()>HighestSell){HighestSell=OrderOpenPrice();MaxSellLot=OrderLots();}
         if(OrderOpenPrice()<LowestSell){LowestSell=OrderOpenPrice();LowestSellTick=OrderTicket();MinSellLot=OrderLots();}
         totalSell=totalSell+1;
         SellSummPriceVol+=OrderOpenPrice()*OrderLots();
         SellSummLots+=OrderLots();
         if(OrderProfit()<0)AllSellProfit=0;
         }
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(OrderOpenPrice()<LowestBuy){LowestBuy=OrderOpenPrice();MinBuyLot=OrderLots();}
         if(OrderOpenPrice()>HighestBuy){HighestBuy=OrderOpenPrice();HighestBuyTick=OrderTicket();MaxBuyLot=OrderLots();}
         totalBuy=totalBuy+1;
         BuySummPriceVol+=OrderOpenPrice()*OrderLots();
         BuySummLots+=OrderLots();
         if(OrderProfit()<0)AllBuyProfit=0;
         }
      }
   MedPriceSell=(SellSummLots>0)?SellSummPriceVol/SellSummLots:0;
   MedPriceBuy=(BuySummLots>0)?BuySummPriceVol/BuySummLots:0;
   MartBuyTP=(MartTakeProfit>0)?MedPriceBuy+MartTakeProfit*Point():0;
   MartSellTP=(MartTakeProfit>0)?MedPriceSell-MartTakeProfit*Point():0;
   
   double MartBuyTrailPos=(MartTrailSize>0)?Bid-MartTrailSize*Point():0;
   double MartSellTrailPos=(MartTrailSize>0)?Ask+MartTrailSize*Point():0;
   
   
   if(HighestBuyTick>-1)OrderSelect(HighestBuyTick, SELECT_BY_TICKET);
   MartBuySL=OrderStopLoss();
   if(SameMartSLTP)MartBuyTP=OrderTakeProfit();
   if(LowestSellTick>-1)OrderSelect(LowestSellTick, SELECT_BY_TICKET);
   MartSellSL=OrderStopLoss();
   if(SameMartSLTP)MartSellTP=OrderTakeProfit();

  MartBuyTP=NormalizeDouble(MartBuyTP,Digits);
  MartBuySL=NormalizeDouble(MartBuySL,Digits);
  MartSellTP=NormalizeDouble(MartSellTP,Digits);
  MartSellSL=NormalizeDouble(MartSellSL,Digits);
  MartBuyTrailPos=NormalizeDouble(MartBuyTrailPos,Digits);
  MartSellTrailPos=NormalizeDouble(MartSellTrailPos,Digits);
   
   if(MartTrailSize>0)
      {
      if(MartBuySL==0)MartBuySL=MartBuyTrailPos;
      MartBuySL=(MartBuyTrailPos>0)?MathMax(MartBuySL,MartBuyTrailPos):MartBuySL;
      if(MartSellSL==0)MartSellSL=MartSellTrailPos;
      MartSellSL=(MartSellTrailPos>0)?MathMin(MartSellSL,MartSellTrailPos):MartSellSL;
      }
   //Print(MedPriceSell," ",MartSellTrailPos," ",MartSellTrailStart," ",MartSellSL);
   
   
   //CorrectMart SL/TP + Trail
   for(int j=0;j<totaln;j++)
      {
      OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(totalBuy>1)
            {
            if(MartTrailSize<=0 || (!Trail1_Active && !Trail2_Active && !Trail3_Active) || ((OrderStopLoss()==0 || OrderStopLoss()<MartBuySL) && (OrderStopLoss()<MartBuySL) && MartBuySL>0))
               {
               //Print(OrderTicket());
               if(OrderStopLoss()!=MartBuySL)if(!OrderModify(OrderTicket(),OrderOpenPrice(),MartBuySL,MartBuyTP,OrderExpiration(),clrNONE))Print("Order Modify error ",MartBuySL," ",MartBuyTP);
               }
               if(OrderTakeProfit()!=MartBuyTP)if(!OrderModify(OrderTicket(),OrderOpenPrice(),MartBuySL,MartBuyTP,OrderExpiration(),clrNONE))Print("Order Modify error ",MartBuySL," ",MartBuyTP);
            }
         }
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
         {
         if(totalSell>1)
            {
            if(MartTrailSize<=0 || (!Trail1_Active && !Trail2_Active && !Trail3_Active) || ((OrderStopLoss()==0 || OrderStopLoss()>MartSellSL ) && (OrderStopLoss()>MartSellSL) && MartSellSL>0))
               {
               //Print(OrderTicket());
               if(OrderStopLoss()!=MartSellSL)if(!OrderModify(OrderTicket(),OrderOpenPrice(),MartSellSL,MartSellTP,OrderExpiration(),clrNONE))Print("Order Modify error ",MartSellSL," ",MartSellTP);
               }
               if(OrderTakeProfit()!=MartSellTP)if(!OrderModify(OrderTicket(),OrderOpenPrice(),MartSellSL,MartSellTP,OrderExpiration(),clrNONE))Print("Order Modify error ",MartSellSL," ",MartSellTP);
            }
         }
      }
   
         
      
      
      
      
      
   if(Trail1_Active || Trail2_Active || Trail3_Active || BEActive>0)
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if(OrderType()<=OP_SELL && Symbol()==OrderSymbol() && OrderMagicNumber()==MagicNumber) 
         {
   //TrailingStop
       //  Print("MDFX");
         if(OrderType()==OP_BUY)
            {
            double CurPrice=MarketInfo(OrderSymbol(),MODE_ASK);
            double MaxTrailPos1=Bid-Trail1*Point();
            double MaxTrailPos2=Bid-Trail1*Point();
            double MaxTrailPos3=Bid-Trail1*Point();
            if(Trail1_MaxProfit && MaxTrailPos1>OrderOpenPrice()+MaxTrail1*Point())MaxTrailPos1=OrderOpenPrice()+MaxTrail1*Point();
            if(Trail2_MaxProfit && MaxTrailPos2>OrderOpenPrice()+MaxTrail2*Point())MaxTrailPos2=OrderOpenPrice()+MaxTrail2*Point();
            if(Trail3_MaxProfit && MaxTrailPos3>OrderOpenPrice()+MaxTrail3*Point())MaxTrailPos3=OrderOpenPrice()+MaxTrail3*Point();
            
               //Print(CurPrice," ",OrderOpenPrice()," ",MarketInfo(OrderSymbol(),MODE_SPREAD)," ",MarketInfo(OrderSymbol(),MODE_POINT)," ",MarketInfo(OrderSymbol(),MODE_STOPLEVEL)," ",
               //TrailingOnAcheavePoints*MarketInfo(OrderSymbol(),MODE_POINT)," ",MaxTrail*MarketInfo(OrderSymbol(),MODE_POINT)," ",OrderStopLoss()," ",CurPrice-MaxTrail*MarketInfo(OrderSymbol(),MODE_POINT));
            if((MaxTrailPos1-Trail1_MinStepPoint*Point()>OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos1<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail1_Active && (Bid-OrderOpenPrice())/Point()>Trail1_Start)
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos1,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError2 ",ErrorDesc(GetLastError()));
            if((MaxTrailPos2-Trail2_MinStepPoint*Point()>OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos2<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail2_Active && (Bid-OrderOpenPrice())/Point()>Trail2_Start)
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos2,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError2 ",ErrorDesc(GetLastError()));
            if((MaxTrailPos3-Trail3_MinStepPoint*Point()>OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos3<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail3_Active && (Bid-OrderOpenPrice())/Point()>Trail3_Start)
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos3,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError2 ",ErrorDesc(GetLastError()));
                 
            }
         if(OrderType()==OP_SELL)
            {
            double CurPrice=MarketInfo(OrderSymbol(),MODE_BID);
            double MaxTrailPos1=Ask+Trail1*Point();
            double MaxTrailPos2=Ask+Trail1*Point();
            double MaxTrailPos3=Ask+Trail1*Point();
            if(Trail1_MaxProfit && MaxTrailPos1<OrderOpenPrice()-MaxTrail1*Point())MaxTrailPos1=OrderOpenPrice()-MaxTrail1*Point();
            if(Trail2_MaxProfit && MaxTrailPos2<OrderOpenPrice()-MaxTrail2*Point())MaxTrailPos2=OrderOpenPrice()-MaxTrail2*Point();
            if(Trail3_MaxProfit && MaxTrailPos3<OrderOpenPrice()-MaxTrail3*Point())MaxTrailPos3=OrderOpenPrice()-MaxTrail3*Point();
              //Print(OrderOpenPrice()," ",CurPrice," ",TrailingOnAcheavePoints*MarketInfo(OrderSymbol(),MODE_POINT));
            if((MaxTrailPos1+Trail1_MinStepPoint*Point()<OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos1>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail1_Active && (OrderOpenPrice()-Ask)/Point()>Trail1_Start)
                   if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos1,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError4 ",NormalizeDouble(MaxTrailPos1,_Digits)," ",ErrorDesc(GetLastError()));
            if((MaxTrailPos2+Trail2_MinStepPoint*Point()<OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos2>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail2_Active && (OrderOpenPrice()-Ask)/Point()>Trail1_Start)
                   if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos2,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError4 ",NormalizeDouble(MaxTrailPos2,_Digits)," ",ErrorDesc(GetLastError()));
            if((MaxTrailPos3+Trail3_MinStepPoint*Point()<OrderStopLoss() || OrderStopLoss()==0) && MaxTrailPos3>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point() && Trail3_Active && (OrderOpenPrice()-Ask)/Point()>Trail1_Start)
                   if(!OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MaxTrailPos3,_Digits),OrderTakeProfit(),0,Green))Print("OrderModifyError4 ",NormalizeDouble(MaxTrailPos3,_Digits)," ",ErrorDesc(GetLastError()));
            }
         }
   //BE
      if(OrderType()<=OP_SELL && BEActive>0) 
         {
         if(OrderType()==OP_BUY)
            {
            //double OrderTP=OrderTakeProfit()-OrderOpenPrice();
            double CurrentProfit=MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice();
            
            if(CurrentProfit>BrkEvnStpPoint*Point() && (OrderStopLoss()<OrderOpenPrice() || OrderStopLoss()==0))
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+BrkEvnPlPips*Point(),OrderTakeProfit(),0,Green))Print("OrderModifyErr BE Buy");
               else Print("Breakeven modified.");
               }
            }
         if(OrderType()==OP_SELL)
            {
            //double OrderTP=OrderOpenPrice()-OrderTakeProfit();
            double CurrentProfit=OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
            if(CurrentProfit>BrkEvnStpPoint*Point() && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0))
               {
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-BrkEvnPlPips*Point(),OrderTakeProfit(),0,Green))Print("OrderModifyErr BE Buy");
               else Print("Breakeven modified.");
               }
            }
         }
      
      }
   
   
  }
//+------------------------------------------------------------------+
string ErrorDesc(int iError)
 {
 //+-------------------------------------------------------------------+
 switch(iError)
  {
  case 0: return("0: No Error");
  case 1: return("1: No Error, Trade Conditions Not Changed");
  case 2: return("2: Common Error");
  case 3: return("3: Invalid Trade Parameters");
  case 4: return("4: Trade Server Is Busy");
  case 5: return("5: Old Version Of The Client Terminal");
  case 6: return("6: No Connection With Trade Server");
  case 7: return("7: Not Enough Rights");
  case 8: return("8: Too Frequent Requests");
  case 9: return("9: Malfunctional Rrade Operation(Never Returned Error)");
  case 64: return("64: Account Disabled");
  case 65: return("65: Invalid Account");
  case 128: return("128: Trade Timeout");
  case 129: return("129: Invalid Price");
  case 130: return("130: Invalid Stops");
  case 131: return("131: Invalid Trade Volume");
  case 132: return("132: Market Is Closed");
  case 133: return("133: Trade Is Disabled");
  case 134: return("134: Not Enough Money");
  case 135: return("135: Price Changed");
  case 136: return("136: Off Quotes");
  case 137: return("137: Broker Is Busy(Never Returned Error)");
  case 138: return("138: Requote");
  case 139: return("139: Order Is Locked");
  case 140: return("140: Long Positions Only Allowed");
  case 141: return("141: Too Many Requests");
  case 145: return("145 Modification Denied Because Order Is Too Close To Market");
  case 146: return("146: Trade Context Is Busy");
  case 147: return("147: Expirations Are Denied By Broker");
  case 148: return("148: Amount Of Open And Pending Orders Has Reached The Limit");
  case 149: return("149: Hedging Is Prohibited");
  case 150: return("150: Prohibited By FIFO Rules");
  case 4000: return("No Error(Never Generated Code)");
  case 4001: return("Wrong Function Pointer");
  case 4002: return("Array Index Is Out Of Range");
  case 4003: return("No Memory For Function Call Stack");
  case 4004: return("Recursive Stack Overflow");
  case 4005: return("Not Enough Stack For Parameter");
  case 4006: return("No Memory For Parameter String");
  case 4007: return("No Memory For Temp String");
  case 4008: return("Non-Initialized String");
  case 4009: return("Non-Initialized String In Array");
  case 4010: return("No Memory For Array String");
  case 4011: return("Too Long String");
  case 4012: return("Remainder From Zero Divide");
  case 4013: return("Zero Divide");
  case 4014: return("Unknown Command");
  case 4015: return("Wrong Jump(Never Generated Error)");
  case 4016: return("Non-Initialized Array");
  case 4017: return("DLL Calls Are Not Allowed");
  case 4018: return("Cannot Load Library");
  case 4019: return("Cannot Call Function");
  case 4020: return("Expert Function Calls Are Not Allowed");
  case 4021: return("Not Enough Memory For Temp String Returned From Function");
  case 4022: return("System Is Busy(Never Generated Error)");
  case 4023: return("DLL-Function Call Critical Error");
  case 4024: return("Internal Error");
  case 4025: return("Out Of Memory");
  case 4026: return("Invalid Pointer");
  case 4027: return("Too Many Formatters In The Format Function");
  case 4028: return("Parameters Count Is More Than Formatters Count");
  case 4029: return("Invalid Array");
  case 4030: return("No Reply From Chart");
  case 4050: return("Invalid Function Parameters Count");
  case 4051: return("Invalid Function Parameter Value");
  case 4052: return("String Function Internal Error");
  case 4053: return("Some Array Error");
  case 4054: return("Incorrect Series Array Usage");
  case 4055: return("Custom Indicator Error");
  case 4056: return("Arrays Are Incompatible");
  case 4057: return("Global Variables Processing Error");
  case 4058: return("Global Variable Not Found");
  case 4059: return("Function Is Not Allowed In Testing Mode");
  case 4060: return("Function Is Not Confirmed");
  case 4061: return("Send Mail Error");
  case 4062: return("String Parameter Expected");
  case 4063: return("Integer Parameter Expected");
  case 4064: return("Double Parameter Expected");
  case 4065: return("Array As Parameter Expected");
  case 4066: return("Requested History Data Is In Update State");
  case 4067: return("Internal Trade Error");
  case 4068: return("Resource Not Found");
  case 4069: return("Resource Not Supported");
  case 4070: return("Duplicate Resource");
  case 4071: return("Cannot Initialize Custom Indicator");
  case 4072: return("Cannot Load Custom Indicator");
  case 4073: return("No History Data");
  case 4074: return("No Memory For History Data");
  case 4099: return("End Of File");
  case 4100: return("Some File Error");
  case 4101: return("Wrong File Name");
  case 4102: return("Too Many Opened Files");
  case 4103: return("Cannot Open File");
  case 4104: return("Incompatible Access To A File");
  case 4105: return("No Order Selected");
  case 4106: return("Unknown Symbol");
  case 4107: return("Invalid Price Parameter For Frade Function");
  case 4108: return("Invalid Ticket");
  case 4109: return("Trade Is Not Allowed In The Expert Properties");
  case 4110: return("Longs Are Not Allowed In The Expert Properties");
  case 4111: return("Shorts Are Not Allowed In the Expert Properties");
  case 4200: return("Object Already Exists");
  case 4201: return("Unknown Object Property");
  case 4202: return("Object Does Not Exist");
  case 4203: return("Unknown Object Type");
  case 4204: return("No Object Name");
  case 4205: return("Object Coordinates Error");
  case 4206: return("No Specified Subwindow");
  case 4207: return("Graphical Object Error");
  case 4210: return("Unknown Chart Property");
  case 4211: return("Chart Not Found");
  case 4212: return("Chart Subwindow Not Found");
  case 4213: return("Chart Indicator Not Found");
  case 4220: return("Dymbol Select Error");
  case 4250: return("Notification Error");
  case 4251: return("Notification Parameter Error");
  case 4252: return("Notifications Disabled");
  case 4253: return("Notification Send Too Frequent");
  case 5001: return("Too Many Opened Files");
  case 5002: return("Wrong File Name");
  case 5003: return("Too Long File Name");
  case 5004: return("Cannot Open File");
  case 5005: return("Text File Buffer Allocation Error");
  case 5006: return("Cannot Delete File");
  case 5007: return("Invalid File Handle(File Closed Or Was Not Opened)");
  case 5008: return("Wrong File Handle(Handle Index Is Out Of Handle Table)");
  case 5009: return("File Must Be Opened With FILE_WRITE Flag");
  case 5010: return("File Must Be Opened With FILE_READ Flag");
  case 5011: return("File Must Be Opened With FILE_BIN Flag");
  case 5012: return("File Must Be Opened With FILE_TXT Flag");
  case 5013: return("File Must Be Opened With FILE_TXT Or FILE_CSV Flag");
  case 5014: return("File Must Be Opened With FILE_CSV Flag");
  case 5015: return("File Read Error");
  case 5016: return("File Write Error");
  case 5017: return("String Size Must Be Specified For Binary File");
  case 5018: return("Incompatible File(For String Arrays-TXT, For Others-BIN)");
  case 5019: return("File Is Directory, Not File");
  case 5020: return("File Does Not Exist");
  case 5021: return("File Cannot Be Rewritten");
  case 5022: return("Wrong Directory Name");
  case 5023: return("Directory Does Not Exist");
  case 5024: return("Specified File Is Not Directory");
  case 5025: return("Cannot Delete Directory");
  case 5026: return("Cannot Clean Directory");
  case 5027: return("Array Resize Error");
  case 5028: return("String Resize Error");
  case 5029: return("Structure Contains Strings Or Dynamic Arrays");
  }
 //+-------------------------------------------------------------------+
 return("Unknown Error");
 }
 
void CreateLabel(string Name,int X,int Y, int FontSize,color Color,bool Back,string Font1,string InitText)
   {
      long Var1;
         if(!ObjectGetInteger(ChartID(),Name,OBJPROP_WIDTH,0,Var1))
         {
         ObjectCreate(ChartID(),Name, OBJ_LABEL,0,0,0);//3,15+25*i// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
         }
      ObjectSetInteger(ChartID(),Name,OBJPROP_XDISTANCE,X); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_YDISTANCE,Y); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_COLOR,Color); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_BACK,Back); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_ZORDER,0); 
      ObjectSetText(Name,InitText,FontSize);
   }   
   
void CheckAndCreateArrowUp(string Name,datetime Time1,double Price1,int Width,color Color,bool Back)
   {
      long Var1;
         if(!ObjectGetInteger(ChartID(),Name,OBJPROP_WIDTH,0,Var1))
         {
         ObjectCreate(Name,OBJ_ARROW_UP,0,Time1,Price1);
         }
      ObjectSetInteger(ChartID(),Name,OBJPROP_TIME1,Time1);
      ObjectSetDouble(ChartID(),Name,OBJPROP_PRICE1,Price1);
      ObjectSetInteger(ChartID(),Name,OBJPROP_BACK,Back);
      ObjectSetInteger(ChartID(),Name,OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSet(Name,OBJPROP_WIDTH,Width);
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),Name,OBJPROP_RAY_RIGHT,0);
      ObjectSetInteger(ChartID(),Name,OBJPROP_COLOR,Color);
   }   
void CheckAndCreateArrowDown(string Name,datetime Time1,double Price1,int Width,color Color,bool Back)
   {
      long Var1;
         if(!ObjectGetInteger(ChartID(),Name,OBJPROP_WIDTH,0,Var1))
         {
         ObjectCreate(Name,OBJ_ARROW_DOWN,0,Time1,Price1);
         }
      ObjectSetInteger(ChartID(),Name,OBJPROP_TIME1,Time1);
      ObjectSetDouble(ChartID(),Name,OBJPROP_PRICE1,Price1);
      ObjectSetInteger(ChartID(),Name,OBJPROP_BACK,Back);
      ObjectSetInteger(ChartID(),Name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(Name,OBJPROP_WIDTH,Width);
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),Name,OBJPROP_RAY_RIGHT,0);
      ObjectSetInteger(ChartID(),Name,OBJPROP_COLOR,Color);
   }