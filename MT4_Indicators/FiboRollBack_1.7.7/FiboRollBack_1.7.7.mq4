//+------------------------------------------------------------------+
//|                                                 FiboRollBack.mq4 |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, A. Zadrutskiy."
#property description "MACD divergence indicator"
#property version   "1.7.7"
#property strict
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot High
#property indicator_label2  "High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Low
#property indicator_label3  "Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Low
#property indicator_label4  "HighFibo1"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
#property indicator_label5  "LowFibo1"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
#property indicator_label6  "TouchFibo1"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

#property indicator_label7  "HighFibo2"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrGreen
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
#property indicator_label8  "LowFibo2"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrGreen
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
#property indicator_label9  "TouchFibo2"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrGreen
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1


input string Div7="*** MA Settings ***";
input int MA1Period=34;
input ENUM_MA_METHOD MA1Type=1;
input ENUM_APPLIED_PRICE MA1Price=0;
input int MA1Shift=1;
input int FiboDeviationPr=3;
input bool OppositeAlerts=0;
input bool NotLookAtMA=0;
input int MaxBarsBack=2000;
input bool PlayAlert=0;
input bool AboveHighOption=0;
input int MinFiboBars=3;
extern string Div25="===Daily Session======";
extern string Yesterday_Time_Start="00:00";
extern string Yesterday_Time_Stop="24:00";

datetime LastAlertTime=0;


//--- indicator buffers
double         MABuffer[];
double         HighBuffer[];
double         LowBuffer[];
double         HighFibo1[];
double         LowFibo1[];
double         TouchFibo1[];
double         HighFibo2[];
double         LowFibo2[];
double         TouchFibo2[];

int Time_Hour_Start=0,Time_Minute_Start=0,Time_Hour_Stop=0,Time_Minute_Stop=0;




datetime StringToTime1(string TimeString)
   {
   int Hour1=StringToInteger(StringSubstr(TimeString,0,2));
   int Min1=StringToInteger(StringSubstr(TimeString,3,2));
   datetime TimeCur=TimeCurrent();
   datetime TimeRes=TimeCur-TimeHour(TimeCur)*60*60-TimeMinute(TimeCur)*60+Hour1*60*60+Min1*60;
   return TimeRes;
   }


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MABuffer);
   SetIndexBuffer(1,HighBuffer);
   SetIndexBuffer(2,LowBuffer);
   SetIndexBuffer(3,HighFibo1);
   SetIndexBuffer(4,LowFibo1);
   SetIndexBuffer(5,TouchFibo1);
   SetIndexBuffer(6,HighFibo2);
   SetIndexBuffer(7,LowFibo2);
   SetIndexBuffer(8,TouchFibo2);
   
   SetIndexArrow(3,119);
   SetIndexArrow(4,119);
   SetIndexArrow(5,119);
   SetIndexArrow(6,119);
   SetIndexArrow(7,119);
   SetIndexArrow(8,119);
   
datetime StartTime=StringToTime1(Yesterday_Time_Start);
datetime StopTime=StringToTime1(Yesterday_Time_Stop);
Time_Hour_Start=TimeHour(StartTime);
Time_Minute_Start=TimeMinute(StartTime);
Time_Hour_Stop=TimeHour(StopTime);
Time_Minute_Stop=TimeMinute(StopTime);
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   int Start;

   if(!IsTesting())Start=Bars-prev_calculated+0;
else Start=Bars-prev_calculated+0;

if(Start>Bars-3)Start=Bars-3;

if(Start>MaxBarsBack)Start=MaxBarsBack;
        // Print(Bars," ",prev_calculated," ",Start);
        int LastSignalDir=-1;
        datetime LastSignalTime=0;
        int LastDnBar=-1,LastUpBar=-1;
   for(int i=Start;i>=0;i--)
      {
      HighFibo1[i]=EMPTY_VALUE;
      LowFibo1[i]=EMPTY_VALUE;
      TouchFibo1[i]=EMPTY_VALUE;
      HighFibo2[i]=EMPTY_VALUE;
      LowFibo2[i]=EMPTY_VALUE;
      TouchFibo2[i]=EMPTY_VALUE;


      MABuffer[i]=iMA(Symbol(),Period(),MA1Period,0,MA1Type,MA1Price,MA1Shift+i);
      double DayHigh=0;
      double DayLow=1000000000;
      int DayHighBar=0,DayLowBar=0;
      int j;
         for(j=i;j<i+1440 && j<Bars-3 && TimeDayOfYear(Time[j])==TimeDayOfYear(Time[i]);j++)
            {
            if(DayHigh<High[j]){DayHigh=High[j];DayHighBar=j;}
            if(DayLow>Low[j]){DayLow=Low[j];DayLowBar=j;}
            }
      double TwoDayHigh=DayHigh;
      double TwoDayLow=DayLow;
      int FirstBarDay=iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,iBarShift(Symbol(),PERIOD_D1,iTime(Symbol(),Period(),i),0)));
      double FirstBarDayHigh=High[(FirstBarDay>=0)?FirstBarDay:iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,i))-1];
      double FirstBarDayLow=Low[(FirstBarDay>=0)?FirstBarDay:iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,i))-1];
     //Print(FirstBarDayHigh," ",FirstBarDayLow);
      
      int TwoDayHighBar=DayHighBar;
      int TwoDayLowBar=DayLowBar;
      int PrevDay=0;
      int CurrDay=TimeDayOfYear(Time[i]);
      for(int k=i;k<i+2880 && k<Bars-3 && PrevDay==0;k++)
         {
         if(TimeDayOfYear(Time[i])!=TimeDayOfYear(Time[k]))PrevDay=TimeDayOfYear(Time[k]);
         }
        
        
         
      for(;j<i+2880 && j<Bars-3 && (TimeDayOfYear(Time[j])==PrevDay || TimeDayOfYear(Time[j])==CurrDay);j++)
            {
            //if(i==166)Print("2 ",i," ",j," ",Time[j]," ",TimeDayOfYear(Time[j])," ",TimeDayOfYear(Time[i]));
            if((TimeHour(Time[j])>Time_Hour_Start || (TimeHour(Time[j])==Time_Hour_Start && TimeMinute(Time[j])>=Time_Minute_Start)) && 
            (TimeHour(Time[j])<Time_Hour_Stop || (TimeHour(Time[j])==Time_Hour_Stop && TimeMinute(Time[j])<=Time_Minute_Stop)))
               {
               if(TwoDayHigh<High[j]){TwoDayHigh=High[j];TwoDayHighBar=j;}
               if(TwoDayLow>Low[j]){TwoDayLow=Low[j];TwoDayLowBar=j;}
               }
            }
      if(DayHigh>0)HighBuffer[i]=DayHigh;
      if(DayLow<1000000000)LowBuffer[i]=DayLow;
      
      double NearestHigh=High[i], NearestLow=Low[i];
      int NearestHighPos=i, NearestLowPos=i;
      bool HighFond=0, LowFond=0;
      for(j=i;j<i+20 && j<Bars-3 && (!HighFond || !LowFond);j++)
         {
         if(!HighFond)
            {
            if(High[j]>NearestHigh){NearestHigh=High[j];NearestHighPos=j;}
            else if(High[j]<NearestHigh)HighFond=1;
            }
         if(!LowFond)
            {
            if(Low[j]<NearestLow){NearestLow=Low[j];NearestLowPos=j;}
            else if(Low[j]>NearestLow)LowFond=1;
            }
         }
      bool Last3Above=0;
      //Close[NearestHighPos]>MABuffer[NearestHighPos] && Close[NearestHighPos+1]>MABuffer[NearestHighPos+1] && Close[NearestHighPos+2]>MABuffer[NearestHighPos+2];
      bool Last3Belowe=0;
      //Close[NearestLowPos]<MABuffer[NearestLowPos] && Close[NearestLowPos+1]<MABuffer[NearestLowPos+1] && Close[NearestLowPos+2]<MABuffer[NearestLowPos+2];
      
      for(j=i;j<i+100 && j<Bars-3 && !Last3Above && !Last3Belowe;j++)
         {
         if(Close[j]>MABuffer[j] && Close[j+1]>MABuffer[j+1] && Close[j+2]>MABuffer[j+2])Last3Above=1;
         if(Close[j]<MABuffer[j] && Close[j+1]<MABuffer[j+1] && Close[j+2]<MABuffer[j+2])Last3Belowe=1;
         }
         
      
      if(Last3Above || NotLookAtMA)
         {
         double FiboLow=Low[NearestHighPos];
         double FiboHigh=DayHigh;
         int HighPos=DayHighBar;
         bool BreakDayHigh=false;
         //if(SizeCurr>SizePrev)
         for(int j=NearestHighPos;j<=TwoDayLowBar && j<Bars;j++)
            {//Check touch down
            if(High[j]>FiboHigh)BreakDayHigh=true;
            if(Low[j]<FiboLow)FiboLow=Low[j];
            if(DayHigh<TwoDayHigh && j>TwoDayHighBar)
               {
               FiboHigh=TwoDayHigh;
               HighPos=TwoDayHighBar;
               }
            
            double Lev38=(FiboHigh-FiboLow)*38.2/100+FiboLow;
            double Lev50=(FiboHigh-FiboLow)*50/100+FiboLow;
            double Lev61=(FiboHigh-FiboLow)*61.8/100+FiboLow;
            double FiboDistance=(FiboHigh-FiboLow)*FiboDeviationPr/100;
            bool BreakDayLow=false;
            for(int n=j;n<=DayHighBar;n++)if(Low[n]<FiboLow)BreakDayLow=true;

            //Print(i," ",NearestHighPos," ",j," ",FiboLow);
            for(int k=NearestHighPos;k>=i;k--)
               {
               double SizeCurr=High[k]-Low[k];//MathAbs(Open[k]-Close[k]);//
               double SizePrev=High[k+1]-Low[k+1];//MathAbs(Open[k+1]-Close[k+1]);//
               bool CloseAt61=Close[k]<=Lev61+FiboDistance && Close[k]>=Lev61-FiboDistance;
               bool CloseAt50=Close[k]<=Lev50+FiboDistance && Close[k]>=Lev50-FiboDistance;
               bool CloseAt38=Close[k]<=Lev38+FiboDistance && Close[k]>=Lev38-FiboDistance;
               bool AboveHigh=Close[k+1]>FirstBarDayHigh || !AboveHighOption;

               bool TouchDn=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]>=Close[k]);//Open[k]>Lev61 && 
               bool TouchUp=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]<=Close[k]);//Open[k]<Lev38 && 
               bool ThreeBars=MathAbs(HighPos-j)>=MinFiboBars;
               if(((TouchDn && !OppositeAlerts && Close[k+1]>Lev61)||(TouchUp && OppositeAlerts && Close[k+1]<Lev61))&&AboveHigh&&!BreakDayHigh&&!BreakDayLow&&ThreeBars)
                  {
                  HighFibo1[k]=FiboHigh;
                  LowFibo1[k]=FiboLow;
                  TouchFibo1[k]=(CloseAt61)?Lev61:((CloseAt50)?Lev50:Lev38);
                  LastDnBar=k;
                  }
               }
            }
            
         FiboLow=Low[NearestHighPos];
         FiboHigh=TwoDayHigh;
         BreakDayHigh=false;
         HighPos=DayHighBar;
         //if(SizeCurr>SizePrev)
         for(int j=NearestHighPos;j<=TwoDayLowBar && j<Bars;j++)
            {//Check touch down
            if(High[j]>FiboHigh)BreakDayHigh=true;
            if(Low[j]<FiboLow)FiboLow=Low[j];
            if(DayHigh<TwoDayHigh && j>TwoDayHighBar)
               {
               FiboHigh=TwoDayHigh;
               HighPos=TwoDayHighBar;
               }
            
            double Lev38=(FiboHigh-FiboLow)*38.2/100+FiboLow;
            double Lev50=(FiboHigh-FiboLow)*50/100+FiboLow;
            double Lev61=(FiboHigh-FiboLow)*61.8/100+FiboLow;
            double FiboDistance=(FiboHigh-FiboLow)*FiboDeviationPr/100;
            bool BreakDayLow=false;
            //for(int n=j;n<=DayLowBar;n++)if(Low[n]<FiboLow)BreakDayLow=true;
            for(int n=j;n<=TwoDayHighBar;n++)if(Low[n]<FiboLow)BreakDayLow=true;

            //Print(i," ",NearestHighPos," ",j," ",FiboLow);
            for(int k=NearestHighPos;k>=i;k--)
               {
               double SizeCurr=High[k]-Low[k];//MathAbs(Open[k]-Close[k]);//
               double SizePrev=High[k+1]-Low[k+1];//MathAbs(Open[k+1]-Close[k+1]);//
               bool AboveHigh=Close[k+1]>FirstBarDayHigh || !AboveHighOption;
               bool CloseAt61=Close[k]<=Lev61+FiboDistance && Close[k]>=Lev61-FiboDistance;
               bool CloseAt50=Close[k]<=Lev50+FiboDistance && Close[k]>=Lev50-FiboDistance;
               bool CloseAt38=Close[k]<=Lev38+FiboDistance && Close[k]>=Lev38-FiboDistance;

               bool TouchDn=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]>=Close[k]);//Open[k]>Lev61 && 
               bool TouchUp=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]<=Close[k]);//Open[k]<Lev38 && 
               bool ThreeBars=MathAbs(HighPos-j)>=MinFiboBars;
               if(((TouchDn && !OppositeAlerts && Close[k+1]>Lev61)||(TouchUp && OppositeAlerts && Close[k+1]<Lev61))&&AboveHigh&&!BreakDayHigh&&!BreakDayLow&&ThreeBars)
                  {
                  HighFibo1[k]=FiboHigh;
                  LowFibo1[k]=FiboLow;
                  TouchFibo1[k]=(CloseAt61)?Lev61:((CloseAt50)?Lev50:Lev38);
                  LastDnBar=k;
                  }
               }
            }
            
         
         }
      if(Last3Belowe || NotLookAtMA)
         {
         double FiboLow=DayLow;
         int LowPos=DayLowBar;
         double FiboHigh=High[NearestLowPos];
         bool BreakDayLow=false;
         //if(SizeCurr>SizePrev)
         for(int j=NearestLowPos;j<=TwoDayHighBar && j<Bars;j++)
            {//Check touch down
            if(Low[j]<FiboLow)BreakDayLow=true;
            if(High[j]>FiboHigh)FiboHigh=High[j];
            if(DayLow>TwoDayLow && j>TwoDayLowBar)
               {
               FiboLow=TwoDayLow;
               LowPos=TwoDayLowBar;
               }
            double Lev38=(FiboHigh-FiboLow)*38.2/100+FiboLow;
            double Lev50=(FiboHigh-FiboLow)*50/100+FiboLow;
            double Lev61=(FiboHigh-FiboLow)*61.8/100+FiboLow;
            double FiboDistance=(FiboHigh-FiboLow)*FiboDeviationPr/100;
            bool BreakDayHigh=false;
            //for(int n=j;n<=DayHighBar;n++)if(High[n]>FiboHigh)BreakDayHigh=true;
            for(int n=j;n<=DayLowBar;n++)if(High[n]>FiboHigh)BreakDayHigh=true;
            
            //Print(i," ",NearestLowPos," ",j," ",FiboHigh);
            for(int k=NearestLowPos;k>=i;k--)
               {
               double SizeCurr=High[k]-Low[k];//MathAbs(Open[k]-Close[k]);//
               double SizePrev=High[k+1]-Low[k+1];//MathAbs(Open[k+1]-Close[k+1]);//
               bool CloseAt61=Close[k]<=Lev61+FiboDistance && Close[k]>=Lev61-FiboDistance;
               bool CloseAt50=Close[k]<=Lev50+FiboDistance && Close[k]>=Lev50-FiboDistance;
               bool CloseAt38=Close[k]<=Lev38+FiboDistance && Close[k]>=Lev38-FiboDistance;
               bool BeloveLow=Close[k+1]<FirstBarDayLow || !AboveHighOption;
               //Print(i," ",j,FiboHigh," ",FiboLow," "," ",Lev38," ",Lev50," ",Lev61);
               bool TouchUp=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]<=Close[k]);//Open[k]<Lev38 && 
               bool TouchDn=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]>=Close[k]);//Open[k]>Lev61 && 
               bool ThreeBars=MathAbs(LowPos-j)>=MinFiboBars;
               if(BeloveLow&&((TouchUp && !OppositeAlerts && Close[k+1]<Lev61)||(TouchDn && OppositeAlerts && Close[k+1]>Lev61))&&!BreakDayLow&&!BreakDayHigh&&ThreeBars)
                  {
                  HighFibo2[k]=FiboHigh;
                  LowFibo2[k]=FiboLow;
                  TouchFibo2[k]=(CloseAt61)?Lev61:((CloseAt50)?Lev50:Lev38);
                  LastUpBar=k;
                  }
               }
            }
         
         FiboLow=TwoDayLow;
         FiboHigh=High[NearestLowPos];
         LowPos=TwoDayLowBar;
         BreakDayLow=false;
         //if(SizeCurr>SizePrev)
         for(int j=NearestLowPos;j<=TwoDayHighBar && j<Bars;j++)
            {//Check touch down
            if(Low[j]<FiboLow)BreakDayLow=true;
            if(High[j]>FiboHigh)FiboHigh=High[j];
            if(DayLow>TwoDayLow && j>TwoDayLowBar)
               {
               FiboLow=TwoDayLow;
               }
            double Lev38=(FiboHigh-FiboLow)*38.2/100+FiboLow;
            double Lev50=(FiboHigh-FiboLow)*50/100+FiboLow;
            double Lev61=(FiboHigh-FiboLow)*61.8/100+FiboLow;
            double FiboDistance=(FiboHigh-FiboLow)*FiboDeviationPr/100;
            bool BreakDayHigh=false;
            //for(int n=j;n<=DayHighBar;n++)if(High[n]>FiboHigh)BreakDayHigh=true;
            for(int n=j;n<=TwoDayLowBar;n++)if(High[n]>FiboHigh)BreakDayHigh=true;
            
            //Print(i," ",NearestLowPos," ",j," ",FiboHigh);
            for(int k=NearestLowPos;k>=i;k--)
               {
               double SizeCurr=High[k]-Low[k];//MathAbs(Open[k]-Close[k]);//
               double SizePrev=High[k+1]-Low[k+1];//MathAbs(Open[k+1]-Close[k+1]);//
               bool CloseAt61=Close[k]<=Lev61+FiboDistance && Close[k]>=Lev61-FiboDistance;
               bool CloseAt50=Close[k]<=Lev50+FiboDistance && Close[k]>=Lev50-FiboDistance;
               bool CloseAt38=Close[k]<=Lev38+FiboDistance && Close[k]>=Lev38-FiboDistance;
               bool BeloveLow=Close[k+1]<FirstBarDayLow || !AboveHighOption;
               //Print(i," ",j,FiboHigh," ",FiboLow," "," ",Lev38," ",Lev50," ",Lev61);
               bool TouchUp=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]<=Close[k]);//Open[k]<Lev38 && 
               bool TouchDn=((CloseAt61 || CloseAt50 || CloseAt38) && SizeCurr>SizePrev && Open[k]>=Close[k]);//Open[k]>Lev61 && 
               bool ThreeBars=MathAbs(LowPos-j)>=MinFiboBars;
               if(BeloveLow&&((TouchUp && !OppositeAlerts && Close[k+1]<Lev61)||(TouchDn && OppositeAlerts && Close[k+1]>Lev61))&&!BreakDayLow&&!BreakDayHigh&&ThreeBars)
                  {
                  HighFibo2[k]=FiboHigh;
                  LowFibo2[k]=FiboLow;
                  TouchFibo2[k]=(CloseAt61)?Lev61:((CloseAt50)?Lev50:Lev38);
                  LastUpBar=k;
                  }
               }
            }
         
         
         
         }
         //Print(DayHigh," ",DayLow);
      }
     
   if(PlayAlert && LastUpBar==1 && LastAlertTime<Time[LastUpBar])
      {
      LastAlertTime=Time[LastUpBar];
      Alert("Alert Up");
      }
   if(PlayAlert && LastDnBar==1 && LastAlertTime<Time[LastDnBar])
      {
      LastAlertTime=Time[LastDnBar];
      Alert("Alert Dn");
      }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
