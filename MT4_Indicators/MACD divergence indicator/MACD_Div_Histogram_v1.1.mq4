//+------------------------------------------------------------------+
//|                                               MACD_Histogram.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, A. Zadrutskiy."
#property description "MACD divergence indicator"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Red



#property indicator_level1 0
//----
#define arrowsDisplacement 0.0001

enum TOSCType
{
OSC_MACD=0,
OSC_RSI=1

};

//---- input parameters
extern string separator1 = "*** OSC Settings ***";
extern TOSCType OSCType=0;
extern int FastMAPeriod = 12;
extern int SlowMAPeriod = 26;
extern int SignalMAPeriod = 9;
extern string separator2 = "*** Indicator Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines = true;
extern bool   displayAlert = true;

extern bool UseClassical=1;
extern bool UseReversal=1;
extern bool PriceNotCrossLine=1;
extern double PriceNotCrossRatio=0.9999;
extern bool OscNotCrossLine=1;
extern double OscNotCrossRatio=1;
extern int MinDistToLastHigh=1;
extern int MaxDistToLastHigh=100;



//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
//double HistogramBuffer[];
double bullishDivergence[];
double bearishDivergence[];

double bullishDivergenceR[];
double bearishDivergenceR[];

//---- variables
double alpha = 0;
double alpha_1 = 0;
//----
static datetime lastAlertTime;
static string   indicatorName;
TOSCType Osc_Last=0;
int Cnt=0;
bool reinit=0;
//int counted_bars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits + 1);
   //---- indicators
   if(OSCType==OSC_MACD)
      {
      SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID,2);
      SetIndexBuffer(0, MACDLineBuffer);
      SetIndexDrawBegin(0, SlowMAPeriod);
      SetIndexStyle(1, DRAW_LINE);
      SetIndexBuffer(1, SignalLineBuffer);
      SetIndexDrawBegin(1, SlowMAPeriod + SignalMAPeriod);
      indicatorName =("MACD(" + FastMAPeriod+"," + SlowMAPeriod + "," + SignalMAPeriod + ")");
      }
   else if(OSCType==OSC_RSI)
      {
      SetIndexStyle(0, DRAW_LINE, STYLE_SOLID,1);
      SetIndexBuffer(0, MACDLineBuffer);
      SetIndexDrawBegin(0, SlowMAPeriod);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexBuffer(1, SignalLineBuffer);
      SetIndexDrawBegin(1, SlowMAPeriod + SignalMAPeriod);
      indicatorName =("RSI(" + FastMAPeriod+ ")");
      }
   
   
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 233);
   SetIndexBuffer(2, bullishDivergence);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234);
   SetIndexBuffer(3, bearishDivergence);
   //---- name for DataWindow and indicator subwindow label
   SetIndexLabel(2, "BullishDivC");
   SetIndexLabel(3, "BearishDivC");
   //----
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 233);
   SetIndexBuffer(4, bullishDivergenceR);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 234);
   SetIndexBuffer(5, bearishDivergenceR);
   //---- name for DataWindow and indicator subwindow label
   SetIndexLabel(4, "BullishDivR");
   SetIndexLabel(5, "BearishDivR");
   //----

   IndicatorShortName(indicatorName);  
	  alpha = 2.0 / (SignalMAPeriod + 1.0);
	  alpha_1 = 1.0 - alpha;
	  Osc_Last=OSCType;
	  EventSetTimer(1);
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnTimer()
{
//datetime EndTime=StringToTime( "2019.03.01 00:00 ");
//if(TimeCurrent()>EndTime)return;





Cnt++;
if(Cnt>5)Cnt=5;
//return;

if(Cnt<2)
   {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
   if(Osc_Last==OSC_MACD)
      {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 19) != "MACD_DivergenceLine")
           continue;
       ObjectDelete(label);
       }
   else if(Osc_Last==OSC_RSI)
      {
       label = ObjectName(i);
       if(StringSubstr(label, 0, 18) != "RSI_DivergenceLine")
           continue;
       ObjectDelete(label);
       }
     }
      CalculateIndicator(0);
   }
else if(Cnt==2)
   {
   int limit;
   int counted_bars = (reinit)?SlowMAPeriod + SignalMAPeriod:IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
   //---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   reinit=0;
   limit = Bars - counted_bars;
      CalculateIndicator(0);
   }
else if(Cnt>2)
   {
   limit;
   counted_bars = (reinit)?SlowMAPeriod + SignalMAPeriod:IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
   //---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   reinit=0;
   limit = Bars - counted_bars;
      CalculateIndicator(counted_bars);
   }


}

int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
   if(Osc_Last==OSC_MACD)
      {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 19) != "MACD_DivergenceLine")
           continue;
       ObjectDelete(label);
       }
   else if(Osc_Last==OSC_RSI)
      {
       label = ObjectName(i);
       if(StringSubstr(label, 0, 18) != "RSI_DivergenceLine")
           continue;
       ObjectDelete(label);
       }
          
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  if(!IsTesting())return 0;
  
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
   //---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   reinit=0;
   limit = Bars - counted_bars;
      CalculateIndicator(counted_bars);
  
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       CalculateMACD(i);
       //CatchBullishDivergence(i + 2);
       CatchDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMACD(int i)
  {
  if(OSCType==OSC_MACD)
   {
   MACDLineBuffer[i] = iMA(NULL, 0, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i) - 
                       iMA(NULL, 0, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
   }
  else if(OSCType==OSC_RSI)
   {
   MACDLineBuffer[i] = iRSI(NULL, 0, FastMAPeriod,PRICE_CLOSE, i);
   }
   SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchDivergence(int shift)
  {
  
   int i=shift;
   bullishDivergence[i]=EMPTY_VALUE;
   bearishDivergence[i]=EMPTY_VALUE;

   bullishDivergenceR[i]=EMPTY_VALUE;
   bearishDivergenceR[i]=EMPTY_VALUE;
  
   
   bool High1OrdMACD=MACDLineBuffer[i+1]<MACDLineBuffer[i] && MACDLineBuffer[i]>MACDLineBuffer[i-1] && MACDLineBuffer[i+2]<MACDLineBuffer[i] && MACDLineBuffer[i]>MACDLineBuffer[i-2];
   bool Low1OrdMACD=MACDLineBuffer[i+1]>MACDLineBuffer[i] && MACDLineBuffer[i]<MACDLineBuffer[i-1] && MACDLineBuffer[i+2]>MACDLineBuffer[i] && MACDLineBuffer[i]<MACDLineBuffer[i-2];
   double HighVal1=MathMax(iHigh(NULL,0,i),MathMax(iHigh(NULL,0,i+1),iHigh(NULL,0,i-1)));
   double LowVal1=MathMin(iLow(NULL,0,i),MathMin(iLow(NULL,0,i+1),iLow(NULL,0,i-1)));
   
   double HighestMACD=-100000;
   double LowestMACD=1000000;
   double HighestMACDPrice=-100000;
   double LowestMACDPrice=1000000;
   
   if(High1OrdMACD)
         {
         int HighPos2=0;
         double PricePos2=0;
         for(int k=shift+MinDistToLastHigh+1;k<MaxDistToLastHigh+shift+1 &&k<Bars-1 && HighPos2==0;k++)
            {
            bool High2OrdMACD=MACDLineBuffer[k+1]<MACDLineBuffer[k] && MACDLineBuffer[k]>MACDLineBuffer[k-1] && MACDLineBuffer[k+2]<MACDLineBuffer[k] && MACDLineBuffer[k]>MACDLineBuffer[k-2];
            double HighVal2=MathMax(iHigh(NULL,0,k),MathMax(iHigh(NULL,0,k+1),iHigh(NULL,0,k-1)));
            
            bool HMACDOk=MACDLineBuffer[i]*OscNotCrossRatio>=HighestMACD || MACDLineBuffer[k]*OscNotCrossRatio>=HighestMACD;
            bool HPriceOk=HighVal1*PriceNotCrossRatio>=HighestMACDPrice || HighVal2*PriceNotCrossRatio>=HighestMACDPrice;

            if(High2OrdMACD && HighPos2==0 && k>=shift+MinDistToLastHigh+1)
               {
               if(UseClassical &&  
               HighVal2<HighVal1 && MACDLineBuffer[k]>MACDLineBuffer[i] && 
               k<shift+MaxDistToLastHigh+1&&
               (!PriceNotCrossLine || HPriceOk)&&
               (!OscNotCrossLine || HMACDOk))
                  {
                  bearishDivergence[i]=MACDLineBuffer[i];
                  HighPos2=k;
                  PricePos2=HighVal2;
                  if(drawPriceTrendLines == true)
                       DrawPriceTrendLine(Time[i], Time[k],HighVal1, HighVal2, Red, STYLE_SOLID);
                  //----
                  if(drawIndicatorTrendLines == true)
                       DrawIndicatorTrendLine(Time[i], Time[k],MACDLineBuffer[i], MACDLineBuffer[k], Red, STYLE_SOLID);
                  if(displayAlert == true && i==2)DisplayAlert("Classical bearish divergence on: ",Symbol());
                  
                  }
               if(UseReversal &&  
               HighVal2>HighVal1 && MACDLineBuffer[k]<MACDLineBuffer[i] && 
               k<shift+MaxDistToLastHigh+1&&
               (!PriceNotCrossLine || HPriceOk)&&
               (!OscNotCrossLine || HMACDOk))
                  {
                  bearishDivergenceR[i]=MACDLineBuffer[i];
                  HighPos2=k;
                  PricePos2=HighVal2;
                  if(drawPriceTrendLines == true)
                       DrawPriceTrendLine(Time[i], Time[k],HighVal1, HighVal2, Red, STYLE_DASH);
                  //----
                  if(drawIndicatorTrendLines == true)
                       DrawIndicatorTrendLine(Time[i], Time[k],MACDLineBuffer[i], MACDLineBuffer[k], Red, STYLE_DASH);
                  
                  if(displayAlert == true && i==2)DisplayAlert("Reverse bearish divergence on: ",Symbol());
                  
                  }
               }
            if(HighestMACD<MACDLineBuffer[k])HighestMACD=MACDLineBuffer[k];
            if(HighestMACDPrice<iHigh(NULL,0,k))HighestMACDPrice=iHigh(NULL,0,k);
            }
         }
      
   if(Low1OrdMACD)
         {
         int LowPos2=0;
         PricePos2=0;
         for(k=shift+MinDistToLastHigh+1;k<MaxDistToLastHigh+shift+1 &&k<Bars-1 && LowPos2==0;k++)
            {
            bool Low2OrdMACD=MACDLineBuffer[k+1]>MACDLineBuffer[k] && MACDLineBuffer[k]<MACDLineBuffer[k-1] && MACDLineBuffer[k+2]>MACDLineBuffer[k] && MACDLineBuffer[k]<MACDLineBuffer[k-2];
            double LowVal2=MathMin(iLow(NULL,0,k),MathMin(iLow(NULL,0,k+1),iLow(NULL,0,k-1)));
            
            bool LMACDOk=MACDLineBuffer[i]<=LowestMACD*OscNotCrossRatio || MACDLineBuffer[k]<=LowestMACD*OscNotCrossRatio;
            bool LPriceOk=LowVal1<=LowestMACDPrice*PriceNotCrossRatio || LowVal2<=LowestMACDPrice*PriceNotCrossRatio;//
            if(Low2OrdMACD && LowPos2==0 && k>=shift+MinDistToLastHigh+1)
               {
               if( UseReversal
                && LowVal2<LowVal1 && MACDLineBuffer[k]>MACDLineBuffer[i] && 
               k<shift+MaxDistToLastHigh+1&&
               (!PriceNotCrossLine || LPriceOk)&&
               (!OscNotCrossLine || LMACDOk)
               )
                  {
                  bullishDivergence[i]=MACDLineBuffer[i];
                  LowPos2=k;
                  PricePos2=LowVal2;
                  if(drawPriceTrendLines == true)
                       DrawPriceTrendLine(Time[i], Time[k],LowVal1, LowVal2, Lime, STYLE_DASH);
                  //----
                  if(drawIndicatorTrendLines == true)
                       DrawIndicatorTrendLine(Time[i], Time[k],MACDLineBuffer[i], MACDLineBuffer[k], Lime, STYLE_DASH);
                  
                  if(displayAlert == true && i==2)DisplayAlert("Reverse bullish divergence on: ",Symbol());
                  
                  }
                  
               if(UseClassical &&  
               LowVal2>LowVal1 && MACDLineBuffer[k]<MACDLineBuffer[i] && 
               k<shift+MaxDistToLastHigh+1&&
               (!PriceNotCrossLine || LPriceOk)&&
               (!OscNotCrossLine || LMACDOk))
                  {
            bullishDivergenceR[i]=MACDLineBuffer[i];

                  LowPos2=k;
                  PricePos2=LowVal2;
                  if(drawPriceTrendLines == true)
                       DrawPriceTrendLine(Time[i], Time[k],LowVal1, LowVal2, Lime, STYLE_SOLID);
                  //----
                  if(drawIndicatorTrendLines == true)
                       DrawIndicatorTrendLine(Time[i], Time[k],MACDLineBuffer[i], MACDLineBuffer[k], Lime, STYLE_SOLID);
                  
                  if(displayAlert == true && i==2)DisplayAlert("Classical bullish divergence on: ",Symbol());
                  
                  }
                  
                  
               }
            if(LowestMACD>MACDLineBuffer[k])LowestMACD=MACDLineBuffer[k];
            if(LowestMACDPrice>iLow(NULL,0,k))LowestMACDPrice=iLow(NULL,0,k);
            }
         }
      
      
      
      
      }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", Period(), " minutes chart");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = ((OSCType==OSC_MACD)?"MACD_DivergenceLine.0# ":"RSI_DivergenceLine.0# ") + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = ((OSCType==OSC_MACD)?"MACD_DivergenceLine.0$# ":"RSI_DivergenceLine.0$# ") + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



