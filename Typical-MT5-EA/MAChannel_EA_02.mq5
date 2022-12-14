#property copyright   A Zadrutskiy
#define  IndicatorBars 50

//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
//---


enum lottype
  {
   Fixed_lot=0,
   Risk_per_trade=1,
  };
enum TTradeDir
  {
   Type_BuySell=1,
   Type_Buy=2,
   Type_Sell=3
  };

enum TTradeMode
   {
   TM_KeepOldTradeOpened=0,
   TM_CloseOldTrade=1
   };

sinput string                 MM_Settings                   ="#################### Money Management Settings ####################";
input double                  FixedLot                       =0.01;
input double                  MaxLot=10000;
sinput string                 MA_Settings              ="#################### MA Settings ####################";
input int MAPeriod=100;
input int MAShift=0;
input ENUM_MA_METHOD MaType=0;
input ENUM_APPLIED_PRICE MaPrice=PRICE_CLOSE;
sinput string                 General_Settings              ="#################### General Settings ####################";
input double                  ChannelUpPoints       = 100;
input double                  ChannelDnPoints          = 100;

input int                     MagicNumber                   =1256119;                              // Magic number (unique ID of EA)
input int                     Slippage                      =5;                                    // Slippage (max difference between order price and market price in points)
input bool                    OpenImmediately=1;
input bool                    OneOpenOneClose=1;
input ENUM_ORDER_TYPE_FILLING OrderFillingType=0;
input TTradeMode OnSecondMaCross=0;
input bool ReverseTraiding=0;
sinput string                 TPSettings                   ="#################### TP ####################";
input int                   TPSize=100;//TP   0 - No TP/SL >0 - Points
sinput string                 SLSettings                   ="#################### SL ####################";
input int                  SLSize=0;//SL   0 - No TP/SL >0 - Points


input string Div25="##########Daily Session###################################################################################";
input bool Trade_Daily_Session_Times_only=true;
input int Trade_Hour_Start=07;
input int Trade_Minute_Start=0;
input int Trade_Hour_Stop=24;
input int Trade_Minute_Stop=0;
input bool Trade_Monday=true;
input bool Trade_Tuesday=true;
input bool Trade_Wednesday=true;
input bool Trade_Thursday=true;
input bool Trade_Friday=true;
input string Div26="##########Hours###################################################################################";
input bool Hour0=true;
input bool Hour1=true;
input bool Hour2=true;
input bool Hour3=true;
input bool Hour4=true;
input bool Hour5=true;
input bool Hour6=true;
input bool Hour7=true;
input bool Hour8=true;
input bool Hour9=true;
input bool Hour10=true;
input bool Hour11=true;
input bool Hour12=true;
input bool Hour13=true;
input bool Hour14=true;
input bool Hour15=true;
input bool Hour16=true;
input bool Hour17=true;
input bool Hour18=true;
input bool Hour19=true;
input bool Hour20=true;
input bool Hour21=true;
input bool Hour22=true;
input bool Hour23=true;
datetime LastBuyTime=0,LastSellTime=0,LastOrderSetTime=0;
bool BuyCloseAll=0;
bool SellCloseAll=0;

bool DailySessionTimeFilter()
   {
   MqlDateTime Tim1;//(TimeCurrent());
   TimeToStruct(TimeCurrent(),Tim1);
  //Print(Tim1.hour," ",Tim1.min);
  bool DayOfWeekOk=
  (Tim1.day_of_week==1 && Trade_Monday) || (Tim1.day_of_week==2 && Trade_Tuesday) || (Tim1.day_of_week==3 && Trade_Wednesday) || 
  (Tim1.day_of_week==4 && Trade_Thursday) || (Tim1.day_of_week==5 && Trade_Friday);

  bool HourOk=
  (Tim1.hour==0 && Hour0) || (Tim1.hour==1 && Hour1) || (Tim1.hour==2 && Hour2) || 
  (Tim1.hour==3 && Hour3) || (Tim1.hour==4 && Hour4) || (Tim1.hour==5 && Hour5) ||
  (Tim1.hour==6 && Hour6) || (Tim1.hour==7 && Hour7) || (Tim1.hour==8 && Hour8) || 
  (Tim1.hour==9 && Hour9) || (Tim1.hour==10 && Hour10) || (Tim1.hour==11 && Hour11);
  (Tim1.hour==12 && Hour12) || (Tim1.hour==13 && Hour13) || (Tim1.hour==14 && Hour14);
  (Tim1.hour==15 && Hour15) || (Tim1.hour==16 && Hour16) || (Tim1.hour==17 && Hour17);
  (Tim1.hour==18 && Hour18) || (Tim1.hour==19 && Hour19) || (Tim1.hour==20 && Hour20);
  (Tim1.hour==21 && Hour21) || (Tim1.hour==22 && Hour22) || (Tim1.hour==23 && Hour23);


   if(Trade_Daily_Session_Times_only)
      {
      if(Trade_Hour_Start<Trade_Hour_Stop || (Trade_Hour_Start==Trade_Hour_Stop && Trade_Minute_Start<Trade_Minute_Stop))
      if(((Tim1.hour>Trade_Hour_Start) || (Tim1.hour==Trade_Hour_Start && Tim1.min>=Trade_Minute_Start))&&
      ((Tim1.hour<Trade_Hour_Stop) || (Tim1.hour==Trade_Hour_Stop && Tim1.min<=Trade_Minute_Stop)))return DayOfWeekOk;
      if(Trade_Hour_Start>Trade_Hour_Stop || (Trade_Hour_Start==Trade_Hour_Stop && Trade_Minute_Start>Trade_Minute_Stop))
      if(((Tim1.hour<Trade_Hour_Stop) || (Tim1.hour==Trade_Hour_Stop && Tim1.min<=Trade_Minute_Stop))||
      ((Tim1.hour>Trade_Hour_Start) || (Tim1.hour==Trade_Hour_Start && Tim1.min>=Trade_Minute_Start)))return DayOfWeekOk && HourOk;
      return false;
      }
   else
      {
      return true;
      }
      return false;
   }


double OnTester()
{
  double  param = 0.0;

//  Balance max + min Drawdown + Trades Number:
  double  balance = TesterStatistics(STAT_PROFIT);
  double  min_dd = TesterStatistics(STAT_BALANCE_DD);
  if(min_dd > 0.0)
  {
    min_dd = 1.0 / min_dd;
  }
  double ProfitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
  ProfitFactor=pow(ProfitFactor,2/4);
  //ProfitFactor=sqrt(ProfitFactor);
  //ProfitFactor=sqrt(ProfitFactor);
  ProfitFactor-=0.9;
  double Sharp = TesterStatistics(STAT_SHARPE_RATIO);
  Sharp=sqrt(Sharp);
  Sharp=sqrt(Sharp);
  double ProfitTrade=TesterStatistics(STAT_EXPECTED_PAYOFF);
  //ProfitTrade=sqrt(ProfitTrade);
  //ProfitTrade=sqrt(ProfitTrade);
  //ProfitTrade=sqrt(ProfitTrade);
  
  param = balance * min_dd * ProfitFactor * Sharp;///ProfitTrade;
  
  if(ProfitTrade>30)param=0;
  if(TesterStatistics(STAT_TRADES)<200)param=0;
   //if(TesterStatistics(STAT_MAX_PROFITTRADE)/TesterStatistics(STAT_EXPECTED_PAYOFF)>50)param=0;
  return(param);
}  
  
//---



int ExtTimeOut=10; // time out in seconds between trade operations

double Parabolic_BufferH[];

int Parabolic_Handle;
bool BuySignal,SellSignal;

//+------------------------------------------------------------------+
//| MACD Sample expert class                                         |
//+------------------------------------------------------------------+
class CSampleExpert
  {
protected:
   double            m_adjusted_point;             // point value adjusted for 3 or 5 points
   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;                     // symbol info object
   CPositionInfo     m_position;                   // trade position object
   CAccountInfo      m_account;                    // account info wrapper
   //--- indicators
   int               m_handle_MA;                // MACD indicator handle
   //--- indicator buffers
   double            m_buff_MA[];           // MACD indicator main buffer
   datetime LastTradeTime;
   //--- indicator data for processing

public:
                     CSampleExpert(void);
                    ~CSampleExpert(void);
   bool              Init(void);
   void              Deinit(void);
   bool              Processing(void);

protected:
   bool              InitCheckParameters(const int digits_adjust);
   bool              InitIndicators(void);
   bool              LongClosed(void);
   bool              ShortClosed(void);
   bool              LongModified(void);
   bool              ShortModified(void);
   bool              LongOpened(void);
   bool              ShortOpened(void);
  };
//--- global expert
CSampleExpert ExtExpert;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSampleExpert::CSampleExpert(void) : m_adjusted_point(0),
                                     m_handle_MA(INVALID_HANDLE)
  {
   m_handle_MA=INVALID_HANDLE;
   LastTradeTime=0;
  
  
  
   ArraySetAsSeries(m_buff_MA,true);
  
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSampleExpert::~CSampleExpert(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//+------------------------------------------------------------------+
bool CSampleExpert::Init(void)
  {
//--- initialize common information
   m_symbol.Name(Symbol());                  // symbol
   m_trade.SetExpertMagicNumber(MagicNumber); // magic
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetTypeFilling(OrderFillingType);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints(3*digits_adjust);
//---
   if(!InitCheckParameters(digits_adjust))
      return(false);
   if(!InitIndicators())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking for input parameters                                    |
//+------------------------------------------------------------------+
bool CSampleExpert::InitCheckParameters(const int digits_adjust)
  {
//--- initial data checks


//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the indicators                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::InitIndicators(void)
  {
  

//--- create Alligator indicator
   if(m_handle_MA==INVALID_HANDLE)
      if((m_handle_MA=iMA(Symbol(),Period(),MAPeriod,MAShift,MaType,MaPrice))==INVALID_HANDLE)
        {
         printf("Error creating Alligator indicator");
         return(false);
        }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Check for long position closing                                  |
//+------------------------------------------------------------------+
bool CSampleExpert::LongClosed(void)
  {
   bool res=false;
   
//--- should it be closed?
      if(false)
           {
            //--- close position
            if(m_trade.PositionClose(Symbol()))
               printf("Long position by %s to be closed",Symbol());
            else
               printf("Error closing position by %s : '%s'",Symbol(),m_trade.ResultComment());
            //--- processed and cannot be modified
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position closing                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortClosed(void)
  {
   bool res=false;
   
//--- should it be closed?
      if(false)
           {
            //--- close position
            if(m_trade.PositionClose(Symbol()))
               printf("Short position by %s to be closed",Symbol());
            else
               printf("Error closing position by %s : '%s'",Symbol(),m_trade.ResultComment());
            //--- processed and cannot be modified
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for long position modifying                                |
//+------------------------------------------------------------------+
bool CSampleExpert::LongModified(void)
  {
   bool res=false;
   int shift=1;

//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position modifying                               |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortModified(void)
  {
   bool   res=false;

//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for long position opening                                  |
//+------------------------------------------------------------------+
bool CSampleExpert::LongOpened(void)
  {
  bool res=false;
  
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position opening                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortOpened(void)
  {
  bool res=false;
  
   return(res);
  }
//+------------------------------------------------------------------+
//| main function returns true if any position processed             |
//+------------------------------------------------------------------+
bool CSampleExpert::Processing(void)
  {
  //OnSecondMaCross=TM_KeepOldTradeOpened=0,
  //TM_CloseOldTrade

  MqlTradeRequest request;
  MqlTradeResult  result;   
  int LotsDigitsAfterPoint=log10(1.0/SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN));
  if(LotsDigitsAfterPoint<1)LotsDigitsAfterPoint=0;else if(LotsDigitsAfterPoint<2)LotsDigitsAfterPoint=1;else if(LotsDigitsAfterPoint<3)LotsDigitsAfterPoint=2;
  
   if(m_handle_MA==INVALID_HANDLE)
      if((m_handle_MA=iMA(Symbol(),Period(),MAPeriod,MAShift,MaType,MaPrice))==INVALID_HANDLE)
        {
         printf("Error creating Alligator indicator");
         return(false);
        }

//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- refresh indicators
      //Print(m_handle_Parabolic," ",BarsCalculated(m_handle_Parabolic),GetLastError());
   if(BarsCalculated(m_handle_MA)<IndicatorBars)
      return(false);
   if(CopyBuffer(m_handle_MA,0,0,IndicatorBars,m_buff_MA)  !=IndicatorBars)
      return(false);
      
      
  int totalBuyStop=0;
  int totalSellStop=0;
  int BuyStopTicket=-1;
  int SellStopTicket=-1;
  string BuyStopComment="";
  int SellStopComment="";
   for(int j=0;j<OrdersTotal();j++)
      {
      ulong  position_ticket=OrderGetTicket(j);// тикет позиции
      string position_symbol=OrderGetString(ORDER_SYMBOL); // символ 
      string position_comment=OrderGetString(ORDER_COMMENT); // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // количество знаков после запятой
      ulong  magic=OrderGetInteger(ORDER_MAGIC); // MagicNumber позиции
      double sl=OrderGetDouble(ORDER_SL);  // Stop Loss позиции
      double tp=OrderGetDouble(ORDER_TP);  // Take Profit позиции
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);  // тип позиции
      //Print(EnumToString(type)," ",magic," ",position_symbol);
      if(type==ORDER_TYPE_SELL_STOP && position_symbol==Symbol() && magic==MagicNumber) 
         {
         totalSellStop++;
         SellStopComment=position_comment;
         SellStopTicket=position_ticket;
         }
      if(type==ORDER_TYPE_BUY_STOP && position_symbol==Symbol() && magic==MagicNumber) 
         {
         totalBuyStop++;
         BuyStopComment=position_comment;
         BuyStopTicket=position_ticket;
         }
      }
      
      
   int totaln=PositionsTotal();
   int total=0,totalBuy=0,totalSell=0;
   bool CloseBuyStop=true;
   bool CloseSellStop=true;
   for(int j=0;j<totaln;j++)
      {
      ulong  position_ticket=PositionGetTicket(j);// тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL); // символ 
      string position_comment=PositionGetString(POSITION_COMMENT); // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);    // объем позиции
      double sl=PositionGetDouble(POSITION_SL);  // Stop Loss позиции
      double tp=PositionGetDouble(POSITION_TP);  // Take Profit позиции
      double PosProfit=PositionGetDouble(POSITION_PROFIT);
      string comment=PositionGetString(POSITION_COMMENT);
      double oPrice=PositionGetDouble(POSITION_PRICE_OPEN); 
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // тип позиции

      if(type<=POSITION_TYPE_SELL && position_symbol==Symbol() && magic==MagicNumber) total=total+1;

      if(type==POSITION_TYPE_SELL && position_symbol==Symbol() && magic==MagicNumber) 
         {
         if(position_comment==BuyStopComment)CloseBuyStop=false;
         totalSell=totalSell+1;
         }
      if(type==POSITION_TYPE_BUY && position_symbol==Symbol() && magic==MagicNumber) 
         {
         if(position_comment==SellStopComment)CloseSellStop=false;
         totalBuy=totalBuy+1;
         }
         
      }

   double CurrentPrice=iClose(Symbol(),Period(),0);
   bool TouchMaCurrent=CurrentPrice<=m_buff_MA[0] && iOpen(Symbol(),Period(),0)>m_buff_MA[0] || CurrentPrice>=m_buff_MA[0] && iOpen(Symbol(),Period(),0)<m_buff_MA[0];
   bool TouchMaClose=iOpen(Symbol(),Period(),1)<=m_buff_MA[1] && iHigh(Symbol(),Period(),1)>m_buff_MA[1] || iOpen(Symbol(),Period(),1)>=m_buff_MA[1] && iLow(Symbol(),Period(),1)<m_buff_MA[1];
   bool InstallLimits=(TouchMaCurrent && OpenImmediately || TouchMaClose && !OpenImmediately) && (totalSell<=0 && totalBuy<=0) && LastOrderSetTime<iTime(Symbol(),Period(),0) && DailySessionTimeFilter();
   double MAPos=(OpenImmediately)?m_buff_MA[0]:m_buff_MA[1];
   bool DeleteBuyStop=(OneOpenOneClose && totalBuyStop>0 && totalSell>0) || (totalBuyStop>0 && InstallLimits);
   bool DeleteSellStop=(OneOpenOneClose && totalSellStop>0 && totalBuy>0) || (totalSellStop>0 && InstallLimits);

   if(DeleteBuyStop && BuyStopTicket>=0)//DeleteLimit
         {
         m_trade.OrderDelete(BuyStopTicket);
         }
   if(DeleteSellStop && SellStopTicket>=0)//DeleteLimit
         {
         m_trade.OrderDelete(SellStopTicket);
         }

   Print(InstallLimits,TouchMaClose,TouchMaCurrent,LastOrderSetTime<iTime(Symbol(),Period(),0),DailySessionTimeFilter());
   Print(Digits()," ",SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)," ",Symbol()," ",m_symbol.Digits(),log10(1/m_symbol.TickSize()),m_symbol.NormalizePrice(1750.12));
   if(InstallLimits)
      {
      //Print("InstallLim");
         double EntryPriceBuy=MAPos+ChannelUpPoints*Point();
         double EntryPriceSell=MAPos-ChannelUpPoints*Point();
         EntryPriceBuy=m_symbol.NormalizePrice(EntryPriceBuy);
         EntryPriceSell=m_symbol.NormalizePrice(EntryPriceSell);
         double SLBuy=0;
         double TPBuy=0;
         double SLSell=0;
         double TPSell=0;
         if(TPSize>0)
            {
            TPBuy=(ReverseTraiding)?EntryPriceSell+TPSize*Point():EntryPriceBuy+TPSize*Point();
            TPSell=(ReverseTraiding)?EntryPriceBuy-TPSize*Point():EntryPriceSell-TPSize*Point();
            
            }
         if(SLSize>0)
            {
            SLBuy=(ReverseTraiding)?EntryPriceSell-SLSize*Point():EntryPriceBuy-SLSize*Point();
            SLSell=(ReverseTraiding)?EntryPriceBuy+SLSize*Point():EntryPriceSell+SLSize*Point();
            
            }
         TPBuy=m_symbol.NormalizePrice(TPBuy);
         TPSell=m_symbol.NormalizePrice(TPSell);
         SLBuy=m_symbol.NormalizePrice(SLBuy);
         SLSell=m_symbol.NormalizePrice(SLSell);
         
         LastOrderSetTime=TimeCurrent();
         double OrderLots1=NormalizeDouble(FixedLot,LotsDigitsAfterPoint);
         if(OrderLots1>MaxLot)OrderLots1=MaxLot;
         if(OrderLots1<m_symbol.LotsMin())OrderLots1=m_symbol.LotsMin();
         if(OrderLots1>m_symbol.LotsMax())OrderLots1=m_symbol.LotsMax();
         //--- check for free money
         
         if(!ReverseTraiding)
            {
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,OrderLots1,EntryPriceBuy)<0.0)
                  printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
                 {
                 m_trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_STOP,OrderLots1,0,EntryPriceBuy,SLBuy,TPBuy,ORDER_TIME_GTC,0,TimeToString(LastOrderSetTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                 }
            
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_SELL,OrderLots1,EntryPriceSell)<0.0)
                  printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
                 {
                 m_trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_STOP,OrderLots1,0,EntryPriceSell,SLSell,TPSell,ORDER_TIME_GTC,0,TimeToString(LastOrderSetTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                 }
            }
         else
            {
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_SELL,OrderLots1,EntryPriceBuy)<0.0)
                  printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
                 {
                 m_trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_LIMIT,OrderLots1,0,EntryPriceBuy,SLSell,TPSell,ORDER_TIME_GTC,0,TimeToString(LastOrderSetTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                 }
            
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,OrderLots1,EntryPriceSell)<0.0)
                  printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
                 {
                 m_trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_LIMIT,OrderLots1,0,EntryPriceSell,SLBuy,TPBuy,ORDER_TIME_GTC,0,TimeToString(LastOrderSetTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                 }
            }
      
      }




//BE  close all
   if(total>0 && (BuyCloseAll||SellCloseAll))// && !ReverseOrder
   for(int j=PositionsTotal()-1;j>=0;j--)
      {
      //PositionsSelect(OrderGetTicket(j));
      //--- параметры ордера
      ulong  position_ticket=PositionGetTicket(j);// тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL); // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);    // объем позиции
      double sl=PositionGetDouble(POSITION_SL);  // Stop Loss позиции
      double tp=PositionGetDouble(POSITION_TP);  // Take Profit позиции
      double price=PositionGetDouble(POSITION_PRICE_OPEN);  // Take Profit позиции
      double Profit=PositionGetDouble(POSITION_PROFIT);  // Take Profit позиции
      
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // тип позиции


      ZeroMemory(request);
      ZeroMemory(result);
      request.action  =TRADE_ACTION_DEAL; // тип торговой операции
      request.magic=magic;
      
      sl=PositionGetDouble(POSITION_SL);  // Stop Loss позиции
//--- параметры ордера
      request.position =position_ticket;          // тикет позиции
      request.symbol   =position_symbol;          // символ 
      request.volume   =volume;                   // объем позиции
      request.volume   =NormalizeDouble(request.volume,LotsDigitsAfterPoint);
      request.deviation=5;                        // допустимое отклонение от цены
      request.type_filling=OrderFillingType;
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }

      if(Symbol()==position_symbol && magic==MagicNumber) 
         {
         if(type==POSITION_TYPE_BUY && BuyCloseAll)
            {
            Print("Opposite signal buy close.");
            request.volume   =volume;
            if(!OrderSend(request,result));
            
            Print("Close result=",result.retcode);
            }
         if(type==POSITION_TYPE_SELL && SellCloseAll)
            {
            Print("Opposite signal sell close.");
            request.volume   =volume;
            if(!OrderSend(request,result));
            Print("Close result=",result.retcode);
            }
         }
      }


      
//--- first check if position exists - try to select it
  /* if(m_position.Select(Symbol()))
     {
      //if(m_position.PositionType()==POSITION_TYPE_BUY)
      //  {
         //--- try to close or modify long position
         if(LongClosed())
            return(true);
         if(LongModified())
            return(true);
      //  }
      //else
      //  {
         //--- try to close or modify short position
         if(ShortClosed())
            return(true);
         if(ShortModified())
            return(true);
      //  }
     }*/
//--- no opened position identified
/*
   if(DailySessionTimeFilter())// && DailyCandlesTimeFilter())
     {
      //--- check for long position (BUY) possibility
      if(BuyOpen && !BuyCloseAll &&(TradeDir==Type_BuySell || TradeDir==Type_Buy) && LastBuyTime<iTime(Symbol(),Period(),0)+1)
         if(LongOpened())
            return(true);
      //--- check for short position (SELL) possibility
      if(SellOpen && !SellCloseAll &&(TradeDir==Type_BuySell || TradeDir==Type_Sell) && LastSellTime<iTime(Symbol(),Period(),0)+1)
         if(ShortOpened())
            return(true);
     }
 */
//--- exit without position processing
   return(false);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- create all necessary objects
   if(!ExtExpert.Init())
      return(INIT_FAILED);
//--- secceed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert new tick handling function                                |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   static datetime limit_time=0; // last trade processing time + timeout
//--- don't process if timeout
   if(TimeCurrent()>=limit_time)
     {
      //--- check for data
      if(Bars(Symbol(),Period())>50)
        {
         //--- change limit time by timeout in seconds if processed
         if(ExtExpert.Processing())
            limit_time=TimeCurrent()+ExtTimeOut;
        }
     }
  }
//+------------------------------------------------------------------+
