//+------------------------------------------------------------------+
//|                                           Pirson_corellation.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, A. Zadrutskiy."
#property description "Pirson corellation indicator for 2 assets"
#property strict

#property indicator_separate_window
#property indicator_buffers    1
#property indicator_color1     DodgerBlue
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int InpPeriod=14;
input string S1="";
input string S2="EURGBP";


//--- buffers
double ExtBuffer[];
double ExtX2Buffer[];
double ExtY2Buffer[];
double ExtXYBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(1,ExtX2Buffer);
   SetIndexBuffer(2,ExtY2Buffer);
   SetIndexBuffer(3,ExtXYBuffer);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtBuffer);
//--- name for DataWindow and indicator subwindow label
   short_name="Corellation("+string(InpPeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//--- check for input
   if(InpPeriod<2)
     {
      Print("Incorrect value for input variable InpPeriod = ",InpPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpPeriod);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,pos;
//---
   if(Bars<=InpPeriod || InpPeriod<2)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtBuffer,false);
   ArraySetAsSeries(ExtX2Buffer,false);
   ArraySetAsSeries(ExtY2Buffer,false);
   ArraySetAsSeries(ExtXYBuffer,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   pos=prev_calculated-1;
   if(pos<0)pos=0;
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
     double Summx2=0, Summy2=0,Summxy=0,Summx=0,Summy=0;
      for(int j=i;j>i-InpPeriod && j>=0;j--)
         {
         Summx2+=iClose(S1,0,Bars-j-1)*iClose(S1,0,Bars-j-1);
         Summy2+=iClose(S2,0,Bars-j-1)*iClose(S2,0,Bars-j-1);
         Summxy+=iClose(S1,0,Bars-j-1)*iClose(S2,0,Bars-j-1);
         Summx+=iClose(S1,0,Bars-j-1);
         Summy+=iClose(S2,0,Bars-j-1);
         }
      //ExtX2Buffer[i]=Summx2;
      //ExtY2Buffer[i]=Summy2;
      //ExtXYBuffer[i]=Summxy;
      double Div=MathSqrt((InpPeriod*Summx2-Summx*Summx)*(InpPeriod*Summy2-Summy*Summy));
      ExtBuffer[i]=(Div>0)?((InpPeriod*Summxy-Summx*Summy)/Div):0;
      }


//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
