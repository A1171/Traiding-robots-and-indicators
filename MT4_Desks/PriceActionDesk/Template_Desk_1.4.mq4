//+------------------------------------------------------------------+
//|                                              PriceActionDesk.mq4 |
//+------------------------------------------------------------------+

#property copyright   "A. Zadrutskiy."

#property indicator_chart_window
#define MaxBarsBack 400
//----
enum TSTRSILine
{
Line_Main=0,
Line_Signal=1
};

extern string Symbols="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,USDJPY,NZDUSD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,USDCHF,NZDJPY,USDCAD,CJN6,SILVER";
extern string Suffix="";
extern int Shift=1;
extern int STDPeriod=20;
extern double DoubleTopSTDPercent=2;
extern double DoubleTop2STDPercent=2;
extern string Div1="=======double top========";
extern bool ShowDoubleTop=false;
extern int ResistAboveBelow=2;
extern string Div2="=======3 bar inside========";
extern bool Show3BarInside=false;
extern string Div3="=======2 double top 1========";
extern bool ShowDoubleTop2_1=false;
extern int MinDoubleTopBars2=4;
extern int MaxDoubleTopBars2=20;
extern string Div4="=======2 double top 2a========";
extern bool ShowDoubleTop2_2a=false;
extern string Div5="=======2 double top 2b========";
extern bool ShowDoubleTop2_2b=false;
extern string Div6="=======2 double top 3========";
extern bool ShowDoubleTop2_3=false;
extern string Div7="=======2 double top 4========";
extern bool ShowDoubleTop2_4=false;

extern string Div10="=======Active Timeframes========";
extern bool     Show_M1=0;
extern bool     Show_M5=1;
extern bool     Show_M15=1;
extern bool     Show_M30=1;
extern bool     Show_M45=1;
extern bool     Show_H1=0;
extern bool     Show_H2=0;
extern bool     Show_H4=0;
extern bool     Show_H8=0;
extern bool     Show_D1=0;
extern bool     Show_W1=0;
extern bool     Show_MN1=0;
extern string Div12="=======Alert========";
extern bool AllertM1=0;
extern bool AllertM5=0;
extern bool AllertM15=0;
extern bool AllertM30=0;
extern bool AllertM45=0;
extern bool AllertH1=1;
extern bool AllertH2=1;
extern bool AllertH4=1;
extern bool AllertH8=1;
extern bool AllertDaily=1;
extern bool AllertWeekly=1;
extern bool AllertMn1=1;
extern string Div13="=======Email========";
extern bool SendMailM1=0;
extern bool SendMailM5=0;
extern bool SendMailM15=0;
extern bool SendMailM30=0;
extern bool SendMailM45=0;
extern bool SendMailH1=0;
extern bool SendMailH2=0;
extern bool SendMailH4=0;
extern bool SendMailH8=0;
extern bool SendMailDaily=1;
extern bool SendMailWeekly=0;
extern bool SendMailMn1=1;
extern string Div14="=======Notify========";
extern bool SendNoteM1=0;
extern bool SendNoteM5=0;
extern bool SendNoteM15=0;
extern bool SendNoteM30=0;
extern bool SendNoteM45=0;
extern bool SendNoteH1=0;
extern bool SendNoteH2=0;
extern bool SendNoteH4=0;
extern bool SendNoteH8=0;
extern bool SendNoteDaily=1;
extern bool SendNoteWeekly=0;
extern bool SendNoteMn1=1;

//extern TADRCompare ADRCompareType=1;
extern string Div15="=======Visualisation========";
extern int x=3;
extern int y=30;
extern color TextColor=clrWhite;
extern color TFColor=clrWhite;
extern color SymbolColor=clrWhite;
extern color PanelColor=clrGray;
extern bool ShowBackGrownd=1;
extern bool ShowBehindeChart=0;
extern int FirstColumnWidth=100;
extern int BaseColumnWidth=70;
extern int BaseColumnHeight=15;
extern int TextFontSize=8;
extern int CaptFontSize=10;
extern int TFFontSize=10;
extern string Font="Verdana";
extern double Scale=1;
extern bool ScaleFont=1;
extern bool Centred=1;
extern int RefreshRate=30;
extern bool ShowLastAlerts=1;
extern int MagicNum=123456;
extern string Div25="===Daily Session======";
extern string Yesterday_Time_Start="00:00";
extern string Yesterday_Time_Stop="24:00";

int Time_Hour_Start=0,Time_Minute_Start=0,Time_Hour_Stop=0,Time_Minute_Stop=0;








datetime StringToTime1(string TimeString)
   {
   int Hour1=StringToInteger(StringSubstr(TimeString,0,2));
   int Min1=StringToInteger(StringSubstr(TimeString,3,2));
   datetime TimeCur=TimeCurrent();
   datetime TimeRes=TimeCur-TimeHour(TimeCur)*60*60-TimeMinute(TimeCur)*60+Hour1*60*60+Min1*60;
   return TimeRes;
   }


#define MaxSymbolsNum 100
#define MaxTimeframe 15

string PairNames[MaxSymbolsNum]={"ADR","AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY",
"EURAUD","EURCAD","USDJPY","NZDUSD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD",
"GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPUSD","USDCHF","NZDJPY","USDCAD","CJN6","SILVER","","","","","","","",""};

datetime FixTimePxTFx[MaxSymbolsNum][14];
string TFCaption[14]={"","M1","M5","M15","M30","M45","H1","H2","H4","H8","D1","W1","MN1"};
ENUM_TIMEFRAMES TFi[14]={0,PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,0,PERIOD_H1,0,PERIOD_H4,0,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
datetime TimeLastExec=0;


bool TriggerUp,TriggerDown;
datetime TimeStartUp,TimeStartDown;
double K,K1,K2,K3,K4;
double Pos,Pos1,Pos2,Pos3,Pos4,Neg,Neg1,Neg2,Neg3,Neg4;

   double PosM150,NegM150,PosM15p1,NegM15m1,PosM15m1,NegM15p1;
   double K_M15,K_M15p,K_M15m;
bool AllertTrigger[MaxTimeframe];
bool MailTrigger[MaxTimeframe];
bool NotifyTrigger[MaxTimeframe];

int TextFontSizeScaled=TextFontSize,CaptFontSizeScaled,TFFontSizeScaled;
datetime LastRefreshTime=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
   //if(TimeDayOfYear(TimeCurrent())>330 && TimeYear(TimeCurrent())>2017)return 0;
  GetSymbolsFromArr();
  TextFontSizeScaled=(ScaleFont)?TextFontSize*Scale:TextFontSize;
  CaptFontSizeScaled=(ScaleFont)?CaptFontSize*Scale:CaptFontSize;
  TFFontSizeScaled=(ScaleFont)?TFFontSize*Scale:TFFontSize;
datetime StartTime=StringToTime1(Yesterday_Time_Start);
datetime StopTime=StringToTime1(Yesterday_Time_Stop);
Time_Hour_Start=TimeHour(StartTime);
Time_Minute_Start=TimeMinute(StartTime);
Time_Hour_Stop=TimeHour(StopTime);
Time_Minute_Stop=TimeMinute(StopTime);
   
  
   int ColumnWidth=FirstColumnWidth;
   int ColumnWidth1=BaseColumnWidth;
   int RowHeight=BaseColumnHeight;
   int RectangleSize=RowHeight*Scale-6;
   int CaptNum=1;
   if(Show_M1){TFCaption[CaptNum]="M1";TFi[CaptNum]=PERIOD_M1;AllertTrigger[CaptNum]=AllertM1;MailTrigger[CaptNum]=SendMailM1;NotifyTrigger[CaptNum]=SendNoteM1; CaptNum++;}
   if(Show_M5){TFCaption[CaptNum]="M5";TFi[CaptNum]=PERIOD_M5;AllertTrigger[CaptNum]=AllertM5;MailTrigger[CaptNum]=SendMailM5;NotifyTrigger[CaptNum]=SendNoteM5;  CaptNum++;}
   if(Show_M15){TFCaption[CaptNum]="M15";TFi[CaptNum]=PERIOD_M15;AllertTrigger[CaptNum]=AllertM15;MailTrigger[CaptNum]=SendMailM15;NotifyTrigger[CaptNum]=SendNoteM15;  CaptNum++;}
   if(Show_M30){TFCaption[CaptNum]="M30";TFi[CaptNum]=PERIOD_M30;AllertTrigger[CaptNum]=AllertM30;MailTrigger[CaptNum]=SendMailM30;NotifyTrigger[CaptNum]=SendNoteM30;  CaptNum++;}
   if(Show_M45){TFCaption[CaptNum]="M45";TFi[CaptNum]=PERIOD_M30;AllertTrigger[CaptNum]=AllertM45;MailTrigger[CaptNum]=SendMailM45;NotifyTrigger[CaptNum]=SendNoteM45;  CaptNum++;}
   if(Show_H1){TFCaption[CaptNum]="H1";TFi[CaptNum]=PERIOD_H1;AllertTrigger[CaptNum]=AllertH1;MailTrigger[CaptNum]=SendMailH1;NotifyTrigger[CaptNum]=SendNoteH1;  CaptNum++;}
   if(Show_H2){TFCaption[CaptNum]="H2";TFi[CaptNum]=PERIOD_H1;AllertTrigger[CaptNum]=AllertH2;MailTrigger[CaptNum]=SendMailH1;NotifyTrigger[CaptNum]=SendNoteH2;  CaptNum++;}
   if(Show_H4){TFCaption[CaptNum]="H4";TFi[CaptNum]=PERIOD_H4;AllertTrigger[CaptNum]=AllertH4;MailTrigger[CaptNum]=SendMailH4;NotifyTrigger[CaptNum]=SendNoteH4;  CaptNum++;}
   if(Show_H8){TFCaption[CaptNum]="H8";TFi[CaptNum]=PERIOD_H4;AllertTrigger[CaptNum]=AllertH8;MailTrigger[CaptNum]=SendMailH8;NotifyTrigger[CaptNum]=SendNoteH8;  CaptNum++;}
   if(Show_D1){TFCaption[CaptNum]="D1";TFi[CaptNum]=PERIOD_D1;AllertTrigger[CaptNum]=AllertDaily;MailTrigger[CaptNum]=SendMailDaily;NotifyTrigger[CaptNum]=SendNoteDaily;  CaptNum++;}
   if(Show_W1){TFCaption[CaptNum]="W1";TFi[CaptNum]=PERIOD_W1;AllertTrigger[CaptNum]=AllertWeekly;MailTrigger[CaptNum]=SendMailWeekly;NotifyTrigger[CaptNum]=SendNoteWeekly;  CaptNum++;}
   if(Show_MN1){TFCaption[CaptNum]="MN1";TFi[CaptNum]=PERIOD_MN1;AllertTrigger[CaptNum]=AllertMn1;MailTrigger[CaptNum]=SendMailMn1;NotifyTrigger[CaptNum]=SendNoteMn1;  CaptNum++;}
   for(int i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")for(int j=0;j<CaptNum;j++)FixTimePxTFx[i][j]=0;

   
  for(i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(0),"_",IntegerToString(MagicNum));
      if(ShowBackGrownd)RectLabelCreate(ChartID(),name1,0,x,y+RowHeight*i*Scale,ColumnWidth*Scale,RowHeight*Scale,PanelColor,BORDER_SUNKEN,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,ShowBehindeChart,false,true,0);
      LabelCreate(name,x+3+RectangleSize+3,y+RowHeight*i*Scale,CORNER_LEFT_UPPER,ShowBehindeChart);
      
      for(j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j),"_",IntegerToString(MagicNum));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j),"_",IntegerToString(MagicNum));
         name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(j),"_",IntegerToString(MagicNum));
         if(ShowBackGrownd)RectLabelCreate(ChartID(),name1,0,x+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,ColumnWidth1*Scale,RowHeight*Scale,PanelColor,BORDER_SUNKEN,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,ShowBehindeChart,false,true,0);
         LabelCreate(name,x+3+RectangleSize+3+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,CORNER_LEFT_UPPER,ShowBehindeChart);
         if(i>0)RectLabelCreate(ChartID(),name2,0,x+3+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+3+RowHeight*i*Scale,RectangleSize,RectangleSize,PanelColor,BORDER_FLAT,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,ShowBehindeChart,false,true,0);
         
         }
      }
      
   EventSetTimer( 5);
   return(0);   


   
   /*
  for(i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0));
      if(ShowBackGrownd)RectLabelCreate(ChartID(),name1,0,x,y+RowHeight*i*Scale,ColumnWidth*Scale,RowHeight*Scale,PanelColor,BORDER_SUNKEN,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,false,false,true,0);
      LabelCreate(name,x+3,y+RowHeight*i*Scale,CORNER_LEFT_UPPER,0);
      
      for(j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j));
         if(ShowBackGrownd)RectLabelCreate(ChartID(),name1,0,x+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,ColumnWidth1*Scale,RowHeight*Scale,PanelColor,BORDER_SUNKEN,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,false,false,true,0);
         
         LabelCreate(name,x+3+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,CORNER_LEFT_UPPER,0);
         
         }
      }
      */
   //TFCaption[2]=IntegerToString(ADR1Period);
   //TFCaption[3]=IntegerToString(ADR2Period);
   //TFCaption[4]=IntegerToString(ADR3Period);
   

   EventSetTimer( 1);
 return(0);   
  }
void OnDeinit(const int Reason)
   {
 Print("Deinit ");
int CaptNum=MaxTimeframe;

  for(int i=0;i<MaxSymbolsNum;i++)
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name2=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0),"_",IntegerToString(MagicNum));
      //Print(name," ",name1);
      long TMPVar;
      if(ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name);
      if(ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name1);
      if(ObjectGetInteger(ChartID(),name2,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name2);
      //ObjectDelete(StringConcatenate(PairNames[i],"_String",IntegerToString(0)));// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
      for(int j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j),"_",IntegerToString(MagicNum));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j),"_",IntegerToString(MagicNum));
         name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(j),"_",IntegerToString(MagicNum));
          if(ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name);// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
         if(ShowBackGrownd)if(ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name1); 
          if(ObjectGetInteger(ChartID(),name2,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name2);// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
         }
      }
   EventKillTimer();
   }
void OnTimer()
  {
//---
  Main();
   
  }
  
  
void GetSymbolsFromArr()
   {
   string Symbols1=","+Symbols;
   int StrLen=StringLen(Symbols1);   
   int SymbPointer=1;
   for(int i=1;i<MaxSymbolsNum;i++)PairNames[i]="";
   if(StrLen>0)
      {
      for(i=0;i<StrLen;i++)
         {
         if(StringSubstr(Symbols1,i,1)==",")
            {
            int NextCommaFont=0;
            for(int j=i+1;j<StrLen;j++)
               {
               if((StringSubstr(Symbols1,j,1)==","||j==StrLen-1)&&NextCommaFont==0)
                  {
                  NextCommaFont=j;
                  if(j<StrLen-1)PairNames[SymbPointer++]=StringSubstr(Symbols1,i+1,j-i-1);
                  else PairNames[SymbPointer++]=StringSubstr(Symbols1,i+1,j-i);
                  i=j-1;j=StrLen;
                  }
               }            
            }
         }
      }
   }
  
  
void CenterStrings()
{
int CaptNum=1;
   if(Show_M1){CaptNum++;}
   if(Show_M5){CaptNum++;}
   if(Show_M15){CaptNum++;}
   if(Show_M30){CaptNum++;}
   if(Show_M45){CaptNum++;}
   if(Show_H1){CaptNum++;}
   if(Show_H2){CaptNum++;}
   if(Show_H4){CaptNum++;}
   if(Show_H8){CaptNum++;}
   if(Show_D1){CaptNum++;}
   if(Show_W1){CaptNum++;}
   if(Show_MN1){CaptNum++;}
  for(int i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0),"_",IntegerToString(MagicNum));
      string name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(0),"_",IntegerToString(MagicNum));
      for(int j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j),"_",IntegerToString(MagicNum));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j),"_",IntegerToString(MagicNum));
         name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(j),"_",IntegerToString(MagicNum));
         if(ShowBackGrownd)
            {
            int X1,Y1,W1,H1,X2,Y2,W2,H2,X3,Y3,W3,H3;
            X1=ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE);
            Y1=ObjectGetInteger(ChartID(),name1,OBJPROP_YDISTANCE);
            W1=ObjectGetInteger(ChartID(),name1,OBJPROP_XSIZE);
            H1=ObjectGetInteger(ChartID(),name1,OBJPROP_YSIZE);
            X2=ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE);
            Y2=ObjectGetInteger(ChartID(),name,OBJPROP_YDISTANCE);
            W2=ObjectGetInteger(ChartID(),name,OBJPROP_XSIZE);
            H2=ObjectGetInteger(ChartID(),name,OBJPROP_YSIZE);
            X3=ObjectGetInteger(ChartID(),name2,OBJPROP_XDISTANCE);
            Y3=ObjectGetInteger(ChartID(),name2,OBJPROP_YDISTANCE);
            W3=ObjectGetInteger(ChartID(),name2,OBJPROP_XSIZE);
            H3=ObjectGetInteger(ChartID(),name2,OBJPROP_YSIZE);
            if(i==0) ObjectSetInteger(ChartID(),name,OBJPROP_XDISTANCE,X1+(W1-W2)/2);
            else ObjectSetInteger(ChartID(),name,OBJPROP_XDISTANCE,X3+W3+(W1-W2-W3)/2);
            ObjectSetInteger(ChartID(),name,OBJPROP_YDISTANCE,Y1+(H1-H2)/2);
            
            }
          }
      }
}
  
void Main()
{

  if(Centred)CenterStrings();
if(TimeCurrent()<LastRefreshTime+RefreshRate)return;
LastRefreshTime=TimeCurrent();


  int WindowBarCount=WindowBarsPerChart();
  datetime TimeCur=TimeCurrent();
  string name=StringConcatenate(PairNames[0],"_String",IntegerToString(0),"_",IntegerToString(MagicNum));
  string name2=StringConcatenate(PairNames[0],"_Panel1",IntegerToString(0),"_",IntegerToString(MagicNum));
  ObjectSetText(name,"", TextFontSizeScaled, Font, TextColor); 
  /**/
  for(int i=1;i<MaxTimeframe;i++)
   {
   name=StringConcatenate(PairNames[0],"_String",IntegerToString(i),"_",IntegerToString(MagicNum));
   ObjectSetText(name,TFCaption[i], TFFontSizeScaled, Font, TFColor); 
   }
   string StrPosx[MaxTimeframe]={"","","","","","","","","","","","","","",""};
   string MailStrPosx[MaxTimeframe]={"","","","","","","","","","","","","","",""};
   string NotifyStrPosx[MaxTimeframe]={"","","","","","","","","","","","","","",""};



int CaptNum=1;
   if(Show_M1){CaptNum++;}
   if(Show_M5){CaptNum++;}
   if(Show_M15){CaptNum++;}
   if(Show_M30){CaptNum++;}
   if(Show_M45){CaptNum++;}
   if(Show_H1){CaptNum++;}
   if(Show_H2){CaptNum++;}
   if(Show_H4){CaptNum++;}
   if(Show_H8){CaptNum++;}
   if(Show_D1){CaptNum++;}
   if(Show_W1){CaptNum++;}
   if(Show_MN1){CaptNum++;}
   for(int j=0;j<MaxTimeframe;j++)StrPosx[j]="";
   //if((TimeCurrent()-TimeLastExec)<5&&iTime(Symbol(),PERIOD_M1,0)<TimeLastExec)   return 1;
   TimeLastExec=TimeCurrent();
   //int Shift1=Shift-1;
  for(i=1;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
     {

     if(MarketInfo(PairNames[i],MODE_POINT)==0)continue;
     name=StringConcatenate(PairNames[i],"_String",IntegerToString(0),"_",IntegerToString(MagicNum));
     name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(0),"_",IntegerToString(MagicNum));
     string Symbol1=PairNames[i]+Suffix;
   int shift=Shift+0;
   string SMB=Symbol1;
     ObjectSetText(name,Symbol1, CaptFontSizeScaled, Font, SymbolColor); 

   ENUM_TIMEFRAMES TF2=PERIOD_M15;
   int Min15FromDayStart=(iTime(SMB,TF2,0)-iTime(SMB,PERIOD_D1,0))/60/15;//TimeCurrent()
   int Bar0PosM45=(Min15FromDayStart%3==0)?0:(((Min15FromDayStart-1)%3==0)?1:2);
   double High45[MaxBarsBack];
   double Low45[MaxBarsBack];
   double Open45[MaxBarsBack];
   double Close45[MaxBarsBack];
   datetime Time45[MaxBarsBack];
   //Form TF
   for(int k=0;k<MaxBarsBack;k++)
      {
      int shift2=Bar0PosM45+k*3;
      High45[k]=iHigh(SMB,TF2,shift2);
      Low45[k]=iLow(SMB,TF2,shift2);
      Open45[k]=iOpen(SMB,TF2,shift2);
      Time45[k]=iTime(SMB,TF2,shift2);
      Close45[k]=iClose(SMB,TF2,shift2);
      for(int l=shift2;l>shift2-3 && l>=0;l--)
         {
         High45[k]=MathMax(High45[k],iHigh(SMB,TF2,l));
         Low45[k]=MathMin(Low45[k],iLow(SMB,TF2,l));
         Close45[k]=iClose(SMB,TF2,l);
         }
      }
   shift2=Bar0PosM45+shift*3;
   
   TF2=PERIOD_H1;
   int HFromDayStart=TimeHour(TimeCurrent());
   int Bar0PosH2=(HFromDayStart%2==0)?0:1;
   shift2=Bar0PosH2+shift*2;
   double High2h[MaxBarsBack];
   double Low2h[MaxBarsBack];
   double Open2h[MaxBarsBack];
   double Close2h[MaxBarsBack];
      datetime Time2h[MaxBarsBack];
   //Form TF
   for(k=0;k<MaxBarsBack;k++)
      {
      shift2=Bar0PosH2+k*2;
      High2h[k]=iHigh(SMB,TF2,shift2);
      Low2h[k]=iLow(SMB,TF2,shift2);
      Open2h[k]=iOpen(SMB,TF2,shift2);
      Time2h[k]=iTime(SMB,TF2,shift2);
      Close2h[k]=iClose(SMB,TF2,shift2);
      for(l=shift2;l>shift2-2 && l>=0;l--)
         {
         High2h[k]=MathMax(High2h[k],iHigh(SMB,TF2,l));
         Low2h[k]=MathMin(Low2h[k],iLow(SMB,TF2,l));
         Close2h[k]=iClose(SMB,TF2,l);
         }
      }
      shift2=Bar0PosH2+shift*2;
      
   TF2=PERIOD_H4;
   int H4FromDayStart=TimeHour(TimeCurrent())/4;
   int Bar0PosH8=(H4FromDayStart%2==0)?0:1;
   shift2=Bar0PosH8+shift*2;
   double High8h[MaxBarsBack];
   double Low8h[MaxBarsBack];
   double Open8h[MaxBarsBack];
   double Close8h[MaxBarsBack];
      datetime Time8h[MaxBarsBack];
   //Form TF
   for(k=0;k<MaxBarsBack;k++)
      {
      shift2=Bar0PosH8+k*2;
      High8h[k]=iHigh(SMB,TF2,shift2);
      Low8h[k]=iLow(SMB,TF2,shift2);
      Open8h[k]=iOpen(SMB,TF2,shift2);
      Time8h[k]=iTime(SMB,TF2,shift2);
      Close8h[k]=iClose(SMB,TF2,shift2);
      for(l=shift2;l>shift2-2 && l>=0;l--)
         {
         High8h[k]=MathMax(High8h[k],iHigh(SMB,TF2,l));
         Low8h[k]=MathMin(Low8h[k],iLow(SMB,TF2,l));
         Close8h[k]=iClose(SMB,TF2,l);
         }
      }   
      shift2=Bar0PosH8+shift*2;
      
      
      double HighCurr[MaxBarsBack];
      double LowCurr[MaxBarsBack];
      double OpenCurr[MaxBarsBack];
      double CloseCurr[MaxBarsBack];
      datetime TimeCurr[MaxBarsBack];
      double MABuffer[MaxBarsBack];
      
      ArraySetAsSeries(HighCurr,true);
      ArraySetAsSeries(LowCurr,true);
      ArraySetAsSeries(OpenCurr,true);
      ArraySetAsSeries(CloseCurr,true);
      ArraySetAsSeries(TimeCurr,true);
      ArraySetAsSeries(MABuffer,true);
     for(j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j),"_",IntegerToString(MagicNum));
         string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j),"_",IntegerToString(MagicNum));
         name2=StringConcatenate(PairNames[i],"_Panel1",IntegerToString(j),"_",IntegerToString(MagicNum));
         ENUM_TIMEFRAMES TF=TFi[j];
   
         if(TFCaption[j]=="M45")
         {
         ArrayCopy(HighCurr,High45);
         ArrayCopy(LowCurr,Low45);
         ArrayCopy(OpenCurr,Open45);
         ArrayCopy(CloseCurr,Close45);
         ArrayCopy(TimeCurr,Time45);
         //Print(j," Cop45 ",HighCurr[0]);
         }
         else if(TFCaption[j]=="H2")
         {
         ArrayCopy(HighCurr,High2h);
         ArrayCopy(LowCurr,Low2h);
         ArrayCopy(OpenCurr,Open2h);
         ArrayCopy(CloseCurr,Close2h);
         ArrayCopy(TimeCurr,Time2h);
         //Print(j," Cop2 ",HighCurr[0]);
         }
         else if(TFCaption[j]=="H8")
         {
         ArrayCopy(HighCurr,High8h);
         ArrayCopy(LowCurr,Low8h);
         ArrayCopy(OpenCurr,Open8h);
         ArrayCopy(CloseCurr,Close8h);
         ArrayCopy(TimeCurr,Time8h);
         //Print(j," Cop8 ",HighCurr[0]);
         }
         else
         {
         CopyClose(PairNames[i],TF,0,MaxBarsBack,CloseCurr);
         CopyOpen(PairNames[i],TF,0,MaxBarsBack,OpenCurr);
         CopyHigh(PairNames[i],TF,0,MaxBarsBack,HighCurr);
         CopyLow(PairNames[i],TF,0,MaxBarsBack,LowCurr);
         CopyTime(PairNames[i],TF,0,MaxBarsBack,TimeCurr);
         //Print(j," CopX ",HighCurr[0]);
         }
         
//if(PairNames[i]=="EURUSD")if(TFCaption[j]=="H8")
//Print(PairNames[i]," ",TFCaption[j]," ",TF," ",Bar0PosH8," ",DoubleToStr(HighCurr[0],Digits)," ",DoubleToStr(LowCurr[0],Digits)," ",DoubleToStr(OpenCurr[0],Digits)," ",DoubleToStr(CloseCurr[0],Digits)," ",TimeToStr(TimeCurr[0],TIME_DATE|TIME_MINUTES));
         
      double ATR50=iATR(SMB,TF,50,shift);



   int DayShift=iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,shift));

   int DayStart=iBarShift(SMB,TF,iTime(SMB,PERIOD_D1,DayShift));
   double HighOfDay=iHighest(SMB,TF,MODE_HIGH,DayStart-(shift),shift);
   double LowOfDay=iLowest(SMB,TF,MODE_LOW,DayStart-(shift),shift);
   
   int LevelUpCnt=0,LevelDnCnt=0;
   double LevelMax=MathMax(iHigh(SMB,TF,shift),iHigh(SMB,TF,shift+1));
   double LevelMin=MathMin(iLow(SMB,TF,shift),iLow(SMB,TF,shift+1));
   for(k=shift+2;k<=DayStart;k++)
      {
      if(iHigh(SMB,TF,k)>LevelMax){LevelMax=iHigh(SMB,TF,k);LevelUpCnt++;}
      if(iLow(SMB,TF,k)<LevelMin){LevelMin=iLow(SMB,TF,k);LevelDnCnt++;}
      }
   
   double STDevDTop1=(iBands(SMB,TF,STDPeriod,0.5,0,PRICE_CLOSE,MODE_UPPER,1)-iBands(SMB,TF,STDPeriod,0.5,0,PRICE_CLOSE,MODE_LOWER,1));

   //Print(shift," ",DayShift," ",DayStart," ",HighOfDay," ",LowOfDay," ",LevelUpCnt," ",LevelDnCnt);
   bool DoubleTop=ShowDoubleTop && iHigh(SMB,TF,shift)>=iHigh(SMB,TF,shift+1)-STDevDTop1*DoubleTopSTDPercent/100 && iHigh(SMB,TF,shift)<=iHigh(SMB,TF,shift+1)+STDevDTop1*DoubleTopSTDPercent/100 && shift!=HighOfDay && shift!=LowOfDay && shift+1!=HighOfDay && shift+1!=LowOfDay && LevelUpCnt<=ResistAboveBelow;;//
   bool DoubleBottom=ShowDoubleTop && iLow(SMB,TF,shift)<=iLow(SMB,TF,shift+1)+STDevDTop1*DoubleTopSTDPercent/100 && iLow(SMB,TF,shift)>=iLow(SMB,TF,shift+1)-STDevDTop1*DoubleTopSTDPercent/100 && shift!=HighOfDay && shift!=LowOfDay && shift+1!=HighOfDay && shift+1!=LowOfDay && LevelDnCnt<=ResistAboveBelow;;//
   
   //if(DoubleTop)Print("DoubleTop ",HighOfDay," ",iHigh(SMB,TF,shift));
   
   bool Tpl3InsUp=Show3BarInside && iHigh(SMB,TF,shift+2)>iHigh(SMB,TF,shift+1) && iHigh(SMB,TF,shift+1)>iHigh(SMB,TF,shift) && //iHigh(SMB,TF,shift+3)>iHigh(SMB,TF,shift) &&
   iLow(SMB,TF,shift+2)<=iLow(SMB,TF,shift+1) && iLow(SMB,TF,shift+1)<=iLow(SMB,TF,shift) && //iLow(SMB,TF,shift+3)<=iLow(SMB,TF,shift) && 
   iHigh(SMB,TF,shift+2)>=iHigh(SMB,TF,HighOfDay) && 
   iTime(SMB,PERIOD_D1,DayShift)<iTime(SMB,TF,shift+2);
   bool Tpl3InsDn=Show3BarInside && iHigh(SMB,TF,shift+2)>=iHigh(SMB,TF,shift+1) && iHigh(SMB,TF,shift+1)>=iHigh(SMB,TF,shift) &&// iHigh(SMB,TF,shift+3)>=iHigh(SMB,TF,shift) &&
   iLow(SMB,TF,shift+2)<iLow(SMB,TF,shift+1) && iLow(SMB,TF,shift+1)<iLow(SMB,TF,shift) && //iLow(SMB,TF,shift+3)<iLow(SMB,TF,shift) &&
   iLow(SMB,TF,shift+2)<=iLow(SMB,TF,LowOfDay) && 
   iTime(SMB,PERIOD_D1,DayShift)<iTime(SMB,TF,shift+2);


   int DTopFond_0=-1,DBottFond_0=-1;
   int DTopFond=-1,DBottFond=-1;
   int DTopFond_2=-1,DBottFond_2=-1;
   bool BrockenDTop_0=0,BrockenDBottom_0=0;
   bool BrockenDTop=0,BrockenDBottom=0;
   bool BrockenDTop_2=0,BrockenDBottom_2=0;
   double HighOfDayVal=iHigh(SMB,TF,shift);
   double LowOfDayVal=iLow(SMB,TF,shift);

   for(k=shift;k<MaxDoubleTopBars2+shift+1;k++)
      {
      bool TimeOk_0=iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,shift))==iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,k));
      bool TimeOk_1=iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,shift+1))==iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,k));
      bool TimeOk_2=iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,shift+2))==iBarShift(SMB,PERIOD_D1,iTime(SMB,TF,k));
      
      if(TimeOk_0)
         {
         if(LowOfDayVal>iLow(SMB,TF,k))LowOfDayVal=iLow(SMB,TF,k);
         if(HighOfDayVal<iHigh(SMB,TF,k))HighOfDayVal=iHigh(SMB,TF,k);
         
         }
      if(k>=MinDoubleTopBars2+shift && MathAbs(iHigh(SMB,TF,shift)-iHigh(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DTopFond_0==-1 && TimeOk_0)DTopFond_0=k;
      if(k>=MinDoubleTopBars2+shift && MathAbs(iLow(SMB,TF,shift)-iLow(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DBottFond_0==-1 && TimeOk_0)DBottFond_0=k;
      if(iHigh(SMB,TF,k)>iHigh(SMB,TF,shift) && DTopFond_0==-1)BrockenDTop_0=true;//+STDevDTop1*DoubleTop2STDPercent/100
      if(iLow(SMB,TF,k)<iLow(SMB,TF,shift) && DBottFond_0==-1)BrockenDBottom_0=true;//-STDevDTop1*DoubleTop2STDPercent/100
      
      if(k>=MinDoubleTopBars2+shift+1 && MathAbs(iHigh(SMB,TF,shift+1)-iHigh(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DTopFond==-1 && TimeOk_1)DTopFond=k;
      if(k>=MinDoubleTopBars2+shift+1 && MathAbs(iLow(SMB,TF,shift+1)-iLow(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DBottFond==-1 && TimeOk_1)DBottFond=k;
      if(iHigh(SMB,TF,k)>iHigh(SMB,TF,shift+1) && DTopFond==-1)BrockenDTop=true;//+STDevDTop1*DoubleTop2STDPercent/100
      if(iLow(SMB,TF,k)<iLow(SMB,TF,shift+1) && DBottFond==-1)BrockenDBottom=true;//-STDevDTop1*DoubleTop2STDPercent/100
      
      if(k>=MinDoubleTopBars2+shift+2 && MathAbs(iHigh(SMB,TF,shift+2)-iHigh(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DTopFond_2==-1 && TimeOk_2)DTopFond_2=k;
      if(k>=MinDoubleTopBars2+shift+2 && MathAbs(iLow(SMB,TF,shift+2)-iLow(SMB,TF,k))<=STDevDTop1*DoubleTop2STDPercent/100 && DBottFond_2==-1 && TimeOk_2)DBottFond_2=k;
      if(iHigh(SMB,TF,k)>iHigh(SMB,TF,shift+2) && DTopFond_2==-1)BrockenDTop_2=true;//+STDevDTop1*DoubleTop2STDPercent/100
      if(iLow(SMB,TF,k)<iLow(SMB,TF,shift+2) && DBottFond_2==-1)BrockenDBottom_2=true;//-STDevDTop1*DoubleTop2STDPercent/100
      }
   bool Bar1LessBarBefore=MathAbs(iOpen(SMB,TF,shift+1)-iClose(SMB,TF,shift+1))<MathAbs(iOpen(SMB,TF,shift+2)-iClose(SMB,TF,shift+2));
      
   bool DoubleTop2_0=DTopFond_0>-1 && !BrockenDTop_0;
   bool DoubleBottom2_0=DBottFond_0>-1 && !BrockenDBottom_0;
   
   bool DoubleTop2_1=DTopFond>-1 && !BrockenDTop;
   bool DoubleBottom2_1=DBottFond>-1 && !BrockenDBottom;
   
   bool DoubleTop2_2=DTopFond_2>-1 && !BrockenDTop_2;
   bool DoubleBottom2_2=DBottFond_2>-1 && !BrockenDBottom_2;

   bool Bar2HammerDojiBear=MathAbs(iOpen(SMB,TF,shift)-iClose(SMB,TF,shift))<=((iClose(SMB,TF,shift)-iLow(SMB,TF,shift))/2) && iClose(SMB,TF,shift)<=iOpen(SMB,TF,shift);
   bool Bar2HammerDojiBull=MathAbs(iOpen(SMB,TF,shift)-iClose(SMB,TF,shift))<=((iHigh(SMB,TF,shift)-iClose(SMB,TF,shift))/2) && iClose(SMB,TF,shift)>=iOpen(SMB,TF,shift);
   
   bool Bar1HammerDojiBear=MathAbs(iOpen(SMB,TF,shift+1)-iClose(SMB,TF,shift+1))<=((MathMin(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1))-iLow(SMB,TF,shift+1))/2);// ||
   //MathAbs(iOpen(SMB,TF,shift+1)-iClose(SMB,TF,shift+1))<=((iLow(SMB,TF,shift+1)-MathMax(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1)))/2);
   bool Bar1HammerDojiBull=MathAbs(iOpen(SMB,TF,shift+1)-iClose(SMB,TF,shift+1))<=((iHigh(SMB,TF,shift+1)-MathMin(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1)))/2) ;   

   bool Bar2Insidebar=iHigh(SMB,TF,shift+1)-iLow(SMB,TF,shift+1)>iHigh(SMB,TF,shift)-iLow(SMB,TF,shift);
   bool Bar2HammerDojiPin=MathAbs(iOpen(SMB,TF,shift)-iClose(SMB,TF,shift))<=((MathMin(iClose(SMB,TF,shift),iOpen(SMB,TF,shift))-iLow(SMB,TF,shift))/2) ||
   MathAbs(iOpen(SMB,TF,shift+1)-iClose(SMB,TF,shift))<=((iLow(SMB,TF,shift)-MathMax(iClose(SMB,TF,shift),iOpen(SMB,TF,shift)))/2);

   bool WickLessThanLeg=(MathMin(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1))-iLow(SMB,TF,shift+1))>(iHigh(SMB,TF,shift+1)-MathMax(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1)));
   bool WickMoreThanLeg=(MathMin(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1))-iLow(SMB,TF,shift+1))<(iHigh(SMB,TF,shift+1)-MathMax(iClose(SMB,TF,shift+1),iOpen(SMB,TF,shift+1)));
   bool ThreeInside=iHigh(SMB,TF,shift+2)>iHigh(SMB,TF,shift+1) && iHigh(SMB,TF,shift+1)>iHigh(SMB,TF,shift) && iLow(SMB,TF,shift+2)<iLow(SMB,TF,shift+1) && iLow(SMB,TF,shift+1)<iLow(SMB,TF,shift);


   
   
   
      bool DoubleTop2_1a=ShowDoubleTop2_1 && DoubleTop2_1 && Bar1LessBarBefore && HighCurr[shift]<=HighCurr[shift+1]+STDevDTop1*DoubleTop2STDPercent/100 && Bar2HammerDojiBear;//
   bool DoubleBottom2_1a=ShowDoubleTop2_1 && DoubleBottom2_1 && Bar1LessBarBefore && LowCurr[shift]>=LowCurr[shift+1]-STDevDTop1*DoubleTop2STDPercent/100 && Bar2HammerDojiBull;//

   bool DoubleTop2_2a=ShowDoubleTop2_2a && DoubleTop2_1 && Bar1LessBarBefore && HighCurr[shift]<=HighCurr[shift+1]+STDevDTop1*DoubleTop2STDPercent/100 && Bar1HammerDojiBear && (Bar2HammerDojiBear || Bar2Insidebar) && (shift+1==HighOfDay || DTopFond==HighOfDay);//
   bool DoubleBottom2_2a=ShowDoubleTop2_2a && DoubleBottom2_1 && Bar1LessBarBefore && LowCurr[shift]>=LowCurr[shift+1]-STDevDTop1*DoubleTop2STDPercent/100 && Bar1HammerDojiBull && (Bar2HammerDojiBull || Bar2Insidebar) && (shift+1==LowOfDay || DBottFond==LowOfDay);//

   bool DoubleTop2_2b=ShowDoubleTop2_2b && DoubleTop2_1 && WickMoreThanLeg && Bar2Insidebar && (shift+1==HighOfDay || DTopFond==HighOfDay);
   bool DoubleBottom2_2b=ShowDoubleTop2_2b && DoubleBottom2_1 && WickLessThanLeg && Bar2Insidebar && (shift+1==LowOfDay || DBottFond==LowOfDay);

   bool DoubleTop2_3=ShowDoubleTop2_3 && DoubleTop2_2 && ThreeInside;//
   bool DoubleBottom2_3=ShowDoubleTop2_3 && DoubleBottom2_2 && ThreeInside;//



   double HighOfDay2=(HighOfDay>-1)?iHighest(SMB,TF,MODE_HIGH,DayStart-(HighOfDay+1),HighOfDay+1):-1;
   double LowOfDay2=(LowOfDay>-1)?iLowest(SMB,TF,MODE_LOW,DayStart-(LowOfDay+1),LowOfDay+1):-1;


   bool DoubleTop2_4=ShowDoubleTop2_4 && DoubleTop2_0 &&HighOfDay2>=0 && DTopFond_0>=0 && DayStart>=DTopFond_0 && DayStart>=HighOfDay2 && HighOfDay>=0  &&  MathAbs(iHigh(SMB,TF,shift)-HighOfDayVal)<=STDevDTop1*DoubleTop2STDPercent/100 && iHigh(SMB,TF,HighOfDay2)<iHigh(SMB,TF,HighOfDay) && (MathAbs(iHigh(SMB,TF,HighOfDay)-iHigh(SMB,TF,shift))<=STDevDTop1*DoubleTop2STDPercent/100 || MathAbs(iHigh(SMB,TF,HighOfDay)-iHigh(SMB,TF,DTopFond_0))<=STDevDTop1*DoubleTop2STDPercent/100);//
   bool DoubleBottom2_4=ShowDoubleTop2_4 && DoubleBottom2_0 && LowOfDay2>=0 && DBottFond_0>=0 && DayStart>=DBottFond_0 && DayStart>=LowOfDay2 && LowOfDay>=0  &&  MathAbs(iLow(SMB,TF,shift)-LowOfDayVal)<=STDevDTop1*DoubleTop2STDPercent/100 && iLow(SMB,TF,LowOfDay2)>iLow(SMB,TF,LowOfDay) && (MathAbs(iLow(SMB,TF,LowOfDay)-iLow(SMB,TF,shift))<=STDevDTop1*DoubleTop2STDPercent/100 || MathAbs(iLow(SMB,TF,LowOfDay)-iLow(SMB,TF,DBottFond_0))<=STDevDTop1*DoubleTop2STDPercent/100);//
 //if(DoubleTop2_4)Print(shift+1," t ",iHigh(SMB,TF,HighOfDay)," ",iHigh(SMB,TF,shift)," ",iHigh(SMB,TF,shift+1)," ",DayStart," ",DTopFond_0);
 //if(DoubleBottom2_4)Print(Time[shift+1]," ",shift+1," b ",iLow(SMB,TF,LowOfDay)," ",iLow(SMB,TF,shift)," ",iLow(SMB,TF,shift+1)," ",DayStart," ",DBottFond_0," ",DBottFond," ",DBottFond_2);

   bool DoubleTop2=DoubleTop2_1a;
   bool DoubleBottom2=DoubleBottom2_1a;

//if(PairNames[i]=="EURUSD")Print(PairNames[i]," ",TFCaption[j]," ",BarBackDown," ",BarBackUp);



   bool Allert=0;
   string SetupsStr="";
   string SetupsMSG="";
         if(DoubleTop)
            {
            SetupsStr=SetupsStr+"DT ";
            SetupsMSG=SetupsMSG+"DT ";
            Allert=1;
            }
         if(Tpl3InsUp)
            {
            SetupsStr=SetupsStr+SetupsStr+"3ins ";
            SetupsMSG=SetupsMSG+SetupsStr+"3ins ";
            Allert=1;
            }   
         if(DoubleTop2_1a)
            {
            SetupsStr=SetupsStr+SetupsStr+"DT2_1";
            SetupsMSG=SetupsMSG+SetupsStr+"DT2_1";
            Allert=1;
            }   
         if(DoubleTop2_2a)
            {
            SetupsStr=SetupsStr+SetupsStr+"DT2_2a";
            SetupsMSG=SetupsMSG+SetupsStr+"DT2_2a";
            Allert=1;
            }   
         if(DoubleTop2_2b)
            {
            SetupsStr=SetupsStr+SetupsStr+"DT2_2b";
            SetupsMSG=SetupsMSG+SetupsStr+"DT2_2b";
            Allert=1;
            }   
         if(DoubleTop2_3)
            {
            SetupsStr=SetupsStr+SetupsStr+"DT2_3";
            SetupsMSG=SetupsMSG+SetupsStr+"DT2_3";
            Allert=1;
            }   
         if(DoubleTop2_4)
            {
            SetupsStr=SetupsStr+SetupsStr+"DT2_4";
            SetupsMSG=SetupsMSG+SetupsStr+"DT2_4";
            Allert=1;
            }   
            
         if(DoubleBottom)
            {
            SetupsStr=SetupsStr+"DB ";
            SetupsMSG=SetupsMSG+"DB ";
            Allert=1;
            }
         if(Tpl3InsDn)
            {
            SetupsStr=SetupsStr+SetupsStr+"3ins ";
            SetupsMSG=SetupsMSG+SetupsStr+"3ins ";
            Allert=1;
            }   
         if(DoubleBottom2_1a)
            {
            SetupsStr=SetupsStr+SetupsStr+"DB2_1";
            SetupsMSG=SetupsMSG+SetupsStr+"DB2_1";
            Allert=1;
            }   
         if(DoubleBottom2_2a)
            {
            SetupsStr=SetupsStr+SetupsStr+"DB2_2a";
            SetupsMSG=SetupsMSG+SetupsStr+"DB2_2a";
            Allert=1;
            }   
         if(DoubleBottom2_2b)
            {
            SetupsStr=SetupsStr+SetupsStr+"DB2_2b";
            SetupsMSG=SetupsMSG+SetupsStr+"DB2_2b";
            Allert=1;
            }   
         if(DoubleBottom2_3)
            {
            SetupsStr=SetupsStr+SetupsStr+"DB2_3";
            SetupsMSG=SetupsMSG+SetupsStr+"DB2_3";
            Allert=1;
            }   
         if(DoubleBottom2_4)
            {
            SetupsStr=SetupsStr+SetupsStr+"DB2_4";
            SetupsMSG=SetupsMSG+SetupsStr+"DB2_4";
            Allert=1;
            }   


         

         



        color PtnClr=(DoubleBottom||Tpl3InsDn||DoubleBottom2_1a||DoubleBottom2_2a||DoubleBottom2_2b||DoubleBottom2_3||DoubleBottom2_4)?clrGreen:((DoubleTop||Tpl3InsUp||DoubleTop2_1a||DoubleTop2_2a||DoubleTop2_2b||DoubleTop2_3||DoubleTop2_4)?clrRed:PanelColor);
         SetupsMSG=SetupsMSG+"Alert.";
         ObjectSetText(name,SetupsStr,TextFontSizeScaled,Font,TextColor);
         ObjectSetInteger(ChartID(),name2,OBJPROP_COLOR,PtnClr);
         ObjectSetInteger(ChartID(),name2,OBJPROP_BGCOLOR,PtnClr);

int SignalAge=shift;

         bool FixTimeConditionM45=FixTimePxTFx[i][j]<TimeCurr[SignalAge] && (Bar0PosM45==0 || FixTimePxTFx[i][j]==0);//FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],SignalAge) && (Bar0PosM45==0 || FixTimePxTFx[i][j]==0);
         bool FixTimeConditionH2=FixTimePxTFx[i][j]<TimeCurr[SignalAge] && (Bar0PosH2==0 || FixTimePxTFx[i][j]==0);//FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],SignalAge) && (Bar0PosH2==0 || FixTimePxTFx[i][j]==0);
         bool FixTimeConditionH8=FixTimePxTFx[i][j]<TimeCurr[SignalAge] && (Bar0PosH8==0 || FixTimePxTFx[i][j]==0);//FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],SignalAge) && (Bar0PosH8==0 || FixTimePxTFx[i][j]==0);
         bool FixTimeConditionAll=FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],SignalAge);

         FixTimeConditionAll=(TFCaption[j]=="M45")?FixTimeConditionM45:((TFCaption[j]=="H2")?FixTimeConditionH2:((TFCaption[j]=="H8")?FixTimeConditionH8:FixTimeConditionAll));
         datetime FixTimeCurr=(TFCaption[j]=="M45")?TimeCurr[SignalAge]:((TFCaption[j]=="H2")?TimeCurr[SignalAge]:((TFCaption[j]=="H8")?TimeCurr[SignalAge]:iTime(Symbol1,TFi[j],SignalAge)));
        //Print(Symbol1," ",TFCaption[j]," ",Allert," ",FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],0)," ",0);
         if(FixTimeConditionAll && Allert)//FixTimePxTFx[i][j]<iTime(Symbol1,TFi[j],0)
               {
               //if(TFCaption[j]=="H8")Print("ghj ",StrPosx[j]);
               if(AllertTrigger[j])
                  {
                  StrPosx[j]=StringConcatenate(StrPosx[j],(StringLen(StrPosx[j])>1)?", ":"",Symbol1," ",TFCaption[j]," ",SetupsMSG);
                  }
               if(MailTrigger[j])
                  {
                  MailStrPosx[j]=StringConcatenate(MailStrPosx[j],(StringLen(MailStrPosx[j])>1)?", ":"",Symbol1," ",TFCaption[j]," ",SetupsMSG);
                  }
               if(NotifyTrigger[j])
                  {
                  NotifyStrPosx[j]=StringConcatenate(NotifyStrPosx[j],(StringLen(NotifyStrPosx[j])>1)?", ":"",Symbol1," ",TFCaption[j]," ",SetupsMSG);
                  }
                  
               FixTimePxTFx[i][j]=FixTimeCurr;//iTime(Symbol1,TFi[j],SignalAge);
               }
         }
     }

          if(StrPosx[1]!=""||StrPosx[2]!=""||StrPosx[3]!=""||StrPosx[4]!=""||StrPosx[5]!=""||StrPosx[6]!=""||StrPosx[7]!=""||StrPosx[8]!=""||StrPosx[9]!=""||StrPosx[10]!=""||StrPosx[11]!=""||StrPosx[12]!=""||StrPosx[13]!=""||StrPosx[14]!="")
            {
            //string AllertMessage=WindowExpertName()+". ";
            for(j=1;j<MaxTimeframe;j++)
               {
               //AllertMessage=StringConcatenate(AllertMessage,StrPosx[j]);
               if(AllertTrigger[j])if(StringLen(StrPosx[j])>1){Alert(TFCaption[j]+StrPosx[j]);}
               }
            //Alert(AllertMessage);
            } 


     string MailString="";
     string NotifyString="";
     
     if(MailStrPosx[1]!=""||MailStrPosx[2]!=""||MailStrPosx[3]!=""||MailStrPosx[4]!=""||MailStrPosx[5]!=""||MailStrPosx[6]!=""||MailStrPosx[7]!=""||MailStrPosx[8]!=""||MailStrPosx[9]!=""||MailStrPosx[10]!=""||MailStrPosx[11]!=""||MailStrPosx[12]!=""||MailStrPosx[13]!=""||MailStrPosx[14]!="")
         {
        for(i=1;i<MaxTimeframe;i++)
            {
            //if(TFCaption[i]=="H8")Print("ghj ",StrPosx[i]);
            if(MailTrigger[i] && StringLen(MailStrPosx[i])>1)MailString=StringConcatenate(MailString,TFCaption[i]," Signals : ",MailStrPosx[i],CharToStr(10));//if(StrPosx[6]!="")
            //Print(i," ",MailTrigger[i]," ",TFCaption[i]," ",MailString); 
            //Print("MailString ",MailString);//
            }
         }
     if(NotifyStrPosx[1]!=""||NotifyStrPosx[2]!=""||NotifyStrPosx[3]!=""||NotifyStrPosx[4]!=""||NotifyStrPosx[5]!=""||NotifyStrPosx[6]!=""||NotifyStrPosx[7]!=""||NotifyStrPosx[8]!=""||NotifyStrPosx[9]!=""||NotifyStrPosx[10]!=""||NotifyStrPosx[11]!=""||NotifyStrPosx[12]!=""||NotifyStrPosx[13]!=""||NotifyStrPosx[14]!="")
         {
        for(i=1;i<MaxTimeframe;i++)
            {
            if(NotifyTrigger[i] && StringLen(NotifyStrPosx[i])>1)NotifyString=StringConcatenate(NotifyString,TFCaption[i]," Signals : ",NotifyStrPosx[i],CharToStr(10));//if(StrPosx[6]!="")
            }
         }
         
         
         //Print(TFCaption[1]);
     if(StringLen(MailString)>1)
         {
         SendMail(WindowExpertName()+" Report ",StringConcatenate(" Signals : ",CharToStr(10),MailString));
         }
     if(StringLen(NotifyString)>1)
         {
         SendNotification(StringConcatenate(WindowExpertName()," Report "," Signals : ",CharToStr(10),NotifyString));
         }


/*     
         StringConcatenate(MailString,TFCaption[8]," Signals : ",StrPosx[8],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[7]," Signals : ",StrPosx[7],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[6]," Signals : ",StrPosx[6],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[5]," Signals : ",StrPosx[5],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[4]," Signals : ",StrPosx[4],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[3]," Signals : ",StrPosx[3],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[2]," Signals : ",StrPosx[2],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         StringConcatenate(MailString,TFCaption[1]," Signals : ",StrPosx[1],CharToStr(10),CharToStr(14));//if(StrPosx[6]!="")
         
         
/*       if(MailTrigger[9]&&MailStrPosx[9]!="")SendMail(WindowExpertName()+" Report "+TFCaption[9],StringConcatenate(TFCaption[9]," Signals : ",CharToStr(10),MailStrPosx[9]));
         if(MailTrigger[8]&&MailStrPosx[8]!="")SendMail(WindowExpertName()+" Report "+TFCaption[8],StringConcatenate(TFCaption[8]," Signals : ",CharToStr(10),MailStrPosx[8]));
         if(MailTrigger[7]&&MailStrPosx[7]!="")SendMail(WindowExpertName()+" Report "+TFCaption[7],StringConcatenate(TFCaption[7]," Signals : ",CharToStr(10),MailStrPosx[7]));
         if(MailTrigger[6]&&MailStrPosx[6]!="")SendMail(WindowExpertName()+" Report "+TFCaption[6],StringConcatenate(TFCaption[6]," Signals : ",CharToStr(10),MailStrPosx[6]));
         if(MailTrigger[5]&&MailStrPosx[5]!="")SendMail(WindowExpertName()+" Report "+TFCaption[5],StringConcatenate(TFCaption[5]," Signals : ",CharToStr(10),MailStrPosx[5]));
         if(MailTrigger[4]&&MailStrPosx[4]!="")SendMail(WindowExpertName()+" Report "+TFCaption[4],StringConcatenate(TFCaption[4]," Signals : ",CharToStr(10),MailStrPosx[4]));
         if(MailTrigger[3]&&MailStrPosx[3]!="")SendMail(WindowExpertName()+" Report "+TFCaption[3],StringConcatenate(TFCaption[3]," Signals : ",CharToStr(10),MailStrPosx[3]));
         if(MailTrigger[2]&&MailStrPosx[2]!="")SendMail(WindowExpertName()+" Report "+TFCaption[2],StringConcatenate(TFCaption[2]," Signals : ",CharToStr(10),MailStrPosx[2]));
         if(MailTrigger[1]&&MailStrPosx[1]!="")SendMail(WindowExpertName()+" Report "+TFCaption[1],StringConcatenate(TFCaption[1]," Signals : ",CharToStr(10),MailStrPosx[1]));

         if(NotifyTrigger[9]&&NotifyStrPosx[9]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[9]," Signals : ",CharToStr(10),MailStrPosx[9]));
         if(NotifyTrigger[8]&&NotifyStrPosx[8]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[8]," Signals : ",CharToStr(10),MailStrPosx[8]));
         if(NotifyTrigger[7]&&NotifyStrPosx[7]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[7]," Signals : ",CharToStr(10),MailStrPosx[7]));
         if(NotifyTrigger[6]&&NotifyStrPosx[6]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[6]," Signals : ",CharToStr(10),MailStrPosx[6]));
         if(NotifyTrigger[5]&&NotifyStrPosx[5]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[5]," Signals : ",CharToStr(10),MailStrPosx[5]));
         if(NotifyTrigger[4]&&NotifyStrPosx[4]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[4]," Signals : ",CharToStr(10),MailStrPosx[4]));
         if(NotifyTrigger[3]&&NotifyStrPosx[3]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[3]," Signals : ",CharToStr(10),MailStrPosx[3]));
         if(NotifyTrigger[2]&&NotifyStrPosx[2]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[2]," Signals : ",CharToStr(10),MailStrPosx[2]));
         if(NotifyTrigger[1]&&NotifyStrPosx[1]!="")SendNotification(StringConcatenate(WindowExpertName()," Report ",TFCaption[1]," Signals : ",CharToStr(10),MailStrPosx[1]));
*/         /*
/*
*/
//Print(MarketInfo(Symbol(),MODE_SWAPLONG)," ",MarketInfo(Symbol(),MODE_SWAPSHORT)," ",MarketInfo(Symbol(),MODE_SWAPTYPE));


}
   
int start()
  {


   return(0);
  }
//+------------------------------------------------------------------+



bool RectLabelCreate(const long              chart_ID=0,
                      const string           name="RectLabel",
                      const int              sub_window=0,
                      const int              x1=0,
                      const int              y1=0,
                      const int              width=50,
                      const int              height=18,
                      const color            back_clr=C'236,233,216',
                      const ENUM_BORDER_TYPE border=BORDER_SUNKEN,
                      const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER,
                      const color            clr=clrRed,
                      const ENUM_LINE_STYLE  style=STYLE_SOLID,
                      const int              line_width=1,
                      const bool             back=false,
                      const bool             selection=false,
                      const bool             hidden=true,
                      const long             z_order=0)
   { 
   ResetLastError(); 
//--- Create Label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) 
     {
      Print(__FUNCTION__, 
            ": не удалось создать прямоугольную метку! Код ошибки = ",GetLastError());
       return(false); 
     }
//--- Set X,Y
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x1); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y1); 
//--- Set size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- Set background
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- Set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border); 
//--- Set tie corner
    ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- Set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- Set border style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- Set border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width); 
//--- Show as backgrownd or not.
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- Set selection
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- Set Hidden Property
    ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- Set mouse click priority
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- Sucessfull execution
   return(true); 
  }   
   
     void LabelCreate(string Name,int DistX,int DistY,int PropCorner, bool Back)
          {
          ObjectCreate(ChartID(),Name,OBJ_LABEL,0,0,0);// 3+100+j*50,15+25*i);// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
      ObjectSetInteger(ChartID(),Name,OBJPROP_XDISTANCE,DistX); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_YDISTANCE,DistY); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_CORNER,PropCorner); 
      //ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_BACK,Back); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_ZORDER,0); 
          //ObjectSetText(StringConcatenate(Name,"_String",IntegerToString(j)),"x",12);
          
          }
