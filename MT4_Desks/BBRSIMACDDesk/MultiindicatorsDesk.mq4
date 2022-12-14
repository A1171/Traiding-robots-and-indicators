//+------------------------------------------------------------------+
//|                                                      b-clock.mq4 |
//|                                     Core time code by Nick Bilak |
//|        http://metatrader.50webs.com/         beluck[at]gmail.com |
//|                                  modified by adoleh2000 and dwt5 | 
//+------------------------------------------------------------------+


enum TSignalType
{
ST_ActiveBar=0,
ST_ClosedBar=1
};

#property copyright "Copyright © 2005, Nick Bilak"
#property link      "http://metatrader.50webs.com/"

#property indicator_chart_window
#define MaxSymbolsNum 100
//----
extern TSignalType SignalOn=1;
extern string Div2="======= RSI ========";
extern int RSI_Period = 14;         //8-25
extern ENUM_APPLIED_PRICE RSIPrice = 0;         //8-25
extern int RSITopLimit = 70;         //8-25
extern int RSIBottomLimit = 30;         //8-25
extern bool AlertRSI=0;
extern string Div3="======= BB ========";
extern int BB_Period=20;
extern double BB_Dev=2;
extern ENUM_APPLIED_PRICE BB_Price=0;
extern bool AlertBB=0;
extern string Div4="======= MACD ========";
extern int MACD_FastEMA=12;
extern double MACD_SlowEMA=26;
extern double MACD_SMA=9;
extern ENUM_APPLIED_PRICE MACD_Price=0;
extern int MACD_LookBack=5;
extern bool AlertMACD=0;

extern string Div5="=======Smbols========";
extern string Symbols="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,USDJPY,NZDUSD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,USDCHF,NZDJPY,USDCAD";
extern string Suffix="";
extern string Div6="=======Visualisation========";
extern int x=3;
extern int y=30;
extern color AlertColor=clrLime;
extern color TextColor=clrWhite;
extern color SymbolColor=clrWhite;
extern color PanelColor=clrGray;
extern bool ShowBackGrownd=1;
extern int FirstColumnWidth=100;
extern int BaseColumnWidth=80;
extern int BaseRowHeight=15;
extern int FontSize=8;
extern string Font="Verdana";
extern double Scale=1;
extern bool ScaleFont=1;
extern bool Centred=1;
extern bool ShowButtons=0;
extern string ChartTemplate="tpl1.tpl";
extern bool AlertAllGreen=1;
extern bool EMailAllGreen=1;
extern bool NotifyAllGreen=1;






/*
""
""
""
0
0
""
0
""
clrRed
clrPink
clrDimGray
clrLawnGreen
clrDarkGreen
""
1
2
0
""
80
70
50
30
20
""
RSIPeriod=21;
PriceLinePeriod=2;
SignalLinePeriod=7;
VolatilityBandPeriod=34
""
*/


string PairNames[MaxSymbolsNum]={"ADR","AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY",
"EURAUD","EURCAD","USDJPY","NZDUSD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD",
"GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPUSD","USDCHF","NZDJPY","USDCAD","CJN6","SILVER","","","","","","","",""};

datetime FixTimePxTFx[MaxSymbolsNum][10];
string TFCaption[10]={"","RSI","Bands","MACD"};
datetime TimeLastExec=0;

bool SymbolSendEMail[MaxSymbolsNum];
datetime LastSignalTime[MaxSymbolsNum];


bool AllertTrigger[10];
int FontSizeScaled=FontSize;
datetime LastAlertTime=0;
datetime LastAllGreenTime=0;
string AllGreenMsg="",AllGreenAMsg="";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
   GetSymbolsFromArr();
  
   FontSizeScaled=(ScaleFont)?FontSize*Scale:FontSize;
   for(int i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")for(int j=0;j<10;j++)FixTimePxTFx[i][j]=0;
   int ColumnWidth=FirstColumnWidth;
   int ColumnWidth1=BaseColumnWidth;
   int RowHeight=BaseRowHeight;
   int CaptNum=1;
   if(1){CaptNum++;}//TFCaption[CaptNum]="%DSm";
   if(1){CaptNum++;}//TFCaption[CaptNum]="%DAvg";
   if(1){CaptNum++;}//TFCaption[CaptNum]="%DAvg";
   if(ShowButtons){CaptNum++;}//TFCaption[CaptNum]="%DAvg";
  for(i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      SymbolSendEMail[i]=1;
      LastSignalTime[i]=0;
      }
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
         if(j<4)
            {
         if(ShowBackGrownd)RectLabelCreate(ChartID(),name1,0,x+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,ColumnWidth1*Scale,RowHeight*Scale,PanelColor,BORDER_SUNKEN,CORNER_LEFT_UPPER,PanelColor,STYLE_SOLID,1,false,false,true,0);
         LabelCreate(name,x+3+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,CORNER_LEFT_UPPER,0);
            }
         if(ShowButtons)if(j==4 && i>0)
            {
            
            CreateButton(name1,x+(ColumnWidth+(j-1)*ColumnWidth1)*Scale,y+RowHeight*i*Scale,ColumnWidth1*Scale,RowHeight*Scale,FontSizeScaled,TextColor,PanelColor,0,Font,"Chart.");
            
            }/**/
         }
      }
      

   EventSetTimer( 5);
 return(0);   
  }
void OnDeinit(const int Reason)
   {
 Print("Deinit ");
   int CaptNum=1;
   if(1){CaptNum++;}//TFCaption[CaptNum]="%DSm";
   if(1){CaptNum++;}//TFCaption[CaptNum]="%DAvg";
   if(1){CaptNum++;}
   if(1){CaptNum++;}

  for(int i=0;i<MaxSymbolsNum;i++)
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0));
      //Print(name," ",name1);
      long TMPVar;
      if(ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name);
      if(ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name1);
      //ObjectDelete(StringConcatenate(PairNames[i],"_String",IntegerToString(0)));// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
      for(int j=1;j<CaptNum;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j));
          if(ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name);// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
         if(ShowBackGrownd)if(ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE,0,TMPVar))ObjectDelete(ChartID(),name1); 
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
   
  for(int i=0;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      string name=StringConcatenate(PairNames[i],"_String",IntegerToString(0));
      string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(0));
      for(int j=1;j<5;j++)
         {
         name=StringConcatenate(PairNames[i],"_String",IntegerToString(j));
         name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j));
         if(ShowBackGrownd)
            {
            int X1,Y1,W1,H1,X2,Y2,W2,H2;
            X1=ObjectGetInteger(ChartID(),name1,OBJPROP_XDISTANCE);
            Y1=ObjectGetInteger(ChartID(),name1,OBJPROP_YDISTANCE);
            W1=ObjectGetInteger(ChartID(),name1,OBJPROP_XSIZE);
            H1=ObjectGetInteger(ChartID(),name1,OBJPROP_YSIZE);
            X2=ObjectGetInteger(ChartID(),name,OBJPROP_XDISTANCE);
            Y2=ObjectGetInteger(ChartID(),name,OBJPROP_YDISTANCE);
            W2=ObjectGetInteger(ChartID(),name,OBJPROP_XSIZE);
            H2=ObjectGetInteger(ChartID(),name,OBJPROP_YSIZE);
            ObjectSetInteger(ChartID(),name,OBJPROP_XDISTANCE,X1+(W1-W2)/2);
            ObjectSetInteger(ChartID(),name,OBJPROP_YDISTANCE,Y1+(H1-H2)/2);
            
            }
          }
      }
}
  
void Main()
{
  if(Centred)CenterStrings();

  int WindowBarCount=WindowBarsPerChart();
  datetime TimeCur=TimeCurrent();
  string name=StringConcatenate(PairNames[0],"_String",IntegerToString(0));
  ObjectSetText(name,"", FontSizeScaled, Font, TextColor); 
  for(int i=1;i<10;i++)
   {
  name=StringConcatenate(PairNames[0],"_String",IntegerToString(i));
  ObjectSetText(name,TFCaption[i], FontSizeScaled, Font, TextColor); 
   
   }
   string AllertStr="";
   string EMailStr="";
   //Print(PairNames[0],PairNames[1],PairNames[2]);
   //string StrPosx[10]={"","","","","","","","","",""};
   //if((TimeCurrent()-TimeLastExec)<5&&iTime(Symbol(),PERIOD_M1,0)<TimeLastExec)   return 1;
   TimeLastExec=TimeCurrent();
   //int Shift1=Shift-1;
   AllGreenMsg="";
   AllGreenAMsg="";
   
   for(i=1;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      name=StringConcatenate(PairNames[i],"_String",IntegerToString(0));
      ObjectSetText(name,PairNames[i], FontSizeScaled, Font, SymbolColor); 
     


string Smb=PairNames[i]+Suffix;
ENUM_TIMEFRAMES TF=Period();

int Shift=(SignalOn==ST_ActiveBar)?0:1;

double RSI=iRSI(Smb,TF,RSI_Period,RSIPrice,Shift);
double BB_Upper=iBands(Smb,TF,BB_Period,BB_Dev,0,BB_Price,MODE_UPPER,Shift);
double BB_Lower=iBands(Smb,TF,BB_Period,BB_Dev,0,BB_Price,MODE_LOWER,Shift);
//double MACD_Main=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift);
//double MACD_Signal=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_SIGNAL,Shift);

//Print(PairNames[i]," ",BB_Upper," ",BB_Lower," ",Close[Shift]);

bool RSIAlert=RSI>RSITopLimit || RSI<RSIBottomLimit;
bool BBAbove=iClose(Smb,TF,Shift)>BB_Upper;
bool BBBelow=iClose(Smb,TF,Shift)<BB_Lower;
bool MacdUp=0,MacdDown=0;
bool MacdUpLast=0,MacdDownLast=0;


for(int k=MACD_LookBack-1;k>=0;k--)
   {
   double MACD1_Main=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift+k);
   //double MACD1_Signal=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_SIGNAL,Shift+k);
   double MACD1_Main_1=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift+1+k);
   //double MACD1_Signal_1=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_SIGNAL,Shift+1+k);
   
   if(MACD1_Main>0 && MACD1_Main_1<=0){MacdUp=1;MacdDown=0;}
   if(MACD1_Main<0 && MACD1_Main_1>=0){MacdDown=1;MacdUp=0;}
   }
   MACD1_Main=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift);
   
   
for(k=MACD_LookBack;k>0;k--)
   {
   double MACD2_Main=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift+k);
   //double MACD1_Signal=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_SIGNAL,Shift+k);
   double MACD2_Main_1=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_MAIN,Shift+1+k);
   //double MACD1_Signal_1=iMACD(Smb,TF,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,MACD_Price,MODE_SIGNAL,Shift+1+k);
   
   if(MACD2_Main>0 && MACD2_Main_1<=0){MacdUpLast=1;MacdDownLast=0;}
   if(MACD2_Main<0 && MACD2_Main_1>=0){MacdDownLast=1;MacdUpLast=0;}
   }
   
bool All3Green=RSIAlert && (BBAbove || BBBelow) && (MacdDown || MacdUp);


if(All3Green && Smb!="")
   {
   AllGreenMsg+=Smb+" "+PeriodToStr(TF)+CharToStr(10)+CharToStr(13);
   AllGreenAMsg+=Smb+" "+PeriodToStr(TF)+"  ";
   }


   int PositionIndex=1;
   string EmptyText="";
   string StrText=DoubleToString(RSI,2);
   color Color1=((RSIAlert)?AlertColor:TextColor);
   name=StringConcatenate(PairNames[i],"_String",IntegerToString(PositionIndex));
   ObjectSetText(name,StrText, FontSizeScaled, Font, Color1); 
     
     PositionIndex++;
      StrText=(BBAbove)?"ABOVE":((BBBelow)?"BELOW":"Within bands");
      Color1=(BBAbove || BBBelow)?AlertColor:TextColor;
      name=StringConcatenate(PairNames[i],"_String",IntegerToString(PositionIndex));
      ObjectSetText(name,StrText, FontSizeScaled, Font, TextColor); 
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,Color1);
      
      PositionIndex++;
      StrText=(MacdUp)?"MACD UP":((MacdDown)?"MACD DOWN":"NoSignals");
      Color1=(MacdUp || MacdDown)?AlertColor:TextColor;
      name=StringConcatenate(PairNames[i],"_String",IntegerToString(PositionIndex));
      ObjectSetText(name,DoubleToStr(MACD1_Main/MarketInfo(Smb,MODE_POINT),1), FontSizeScaled, Font, TextColor); 
      ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,Color1);
      
      
      if(RSIAlert)
            {
            if(AlertRSI)AllertStr=AllertStr+Smb+" "+"RSIAlert.  ";
            }
      if(BBAbove)
            {
            if(AlertBB)AllertStr=AllertStr+Smb+" "+"BB Alert.  ";
            }
      if(BBBelow)
            {
            if(AlertBB)AllertStr=AllertStr+Smb+" "+"BB Alert.  ";
            }
      if(MacdUp && !MacdUpLast)
            {
            if(AlertMACD)AllertStr=AllertStr+Smb+" "+"MACD Alert.  ";
            }
      if(MacdDown && !MacdDownLast)
            {
            if(AlertMACD)AllertStr=AllertStr+Smb+" "+"MACD Alert.  ";
            }



      }
      if(AllertStr!="" && LastAlertTime<Time[0])
         {
         Alert(AllertStr);
         LastAlertTime=TimeCurrent();
         }
         
   if(LastAllGreenTime<Time[0] && AllGreenMsg!="")
      {
      LastAllGreenTime=Time[0];
      if(AlertAllGreen)Alert(AllGreenAMsg+" All indicators Green");
      if(EMailAllGreen)SendMail("Multiindicator desk alert",AllGreenMsg+" All indicators Green");
      if(NotifyAllGreen)SendNotification(AllGreenMsg+"All indicators Green");
      }




/*
if(AllertStr!="" && ShowAllert)Alert(AllertStr);
if(AllertStr!="" && SendNotification1)SendNotification(AllertStr);

if(EMailStr!="")SendMail(WindowExpertName()+" Report.",EMailStr);
*/


}
   
int start()
  {
  //Print("tick");
  Main();

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
   

void CreateButton(string Name,int X,int Y,int XSIZE,int YSIZE, int FontSize1,color FontColor,color Color,bool Back,string Font1,string InitText)
   {
      long Var1;
         if(!ObjectGetInteger(ChartID(),Name,OBJPROP_COLOR,0,Var1))
         {
         ObjectCreate(ChartID(),Name, OBJ_BUTTON,0,0,0);//3,15+25*i// 0, Time[25], WindowPriceMax(0)-(PriceMax-PriceMin)/26*(i+1));
         }
      ObjectSetInteger(ChartID(),Name,OBJPROP_XDISTANCE,X); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_YDISTANCE,Y); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_XSIZE,XSIZE); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_YSIZE,YSIZE); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_COLOR,FontColor); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_BGCOLOR,Color); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_FONTSIZE,FontSize1);
      ObjectSetInteger(ChartID(),Name,OBJPROP_BACK,Back); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,0); 
      ObjectSetInteger(ChartID(),Name,OBJPROP_ZORDER,0); 
      ObjectSetText(Name,InitText,FontSize);
   }   
   

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CLICK)
   {

  for(int i=1;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      int j=4;
         string name=StringConcatenate(PairNames[i],"_String",IntegerToString(j));
         string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j));
         if(sparam==name1)
            {
            long ChID=ChartCheckAndOpen(PairNames[i]+Suffix,Period());
            ChartApplyTemplate(ChID,ChartTemplate);
            ButtonUnpress();
            }
      }
    }
  }

void ButtonUnpress()
{
  for(int i=1;i<MaxSymbolsNum;i++)if(PairNames[i]!="")
      {
      int j=4;
         string name=StringConcatenate(PairNames[i],"_String",IntegerToString(j));
         string name1=StringConcatenate(PairNames[i],"_Panel",IntegerToString(j));
         if(ObjectGetInteger(0,name1,OBJPROP_STATE)==1)
         ObjectSetInteger(0,name1,OBJPROP_STATE,0);
      }

}


   string PeriodToStr(int Per)
   {
   switch(Per)
   {
   case 1:   return "M1";
   case 5:   return "M5";
   case 15:   return "M15";
   case 30:   return "M30";
   case 60:   return "H1";
   case 240:   return "H4";
   case 1440:   return "D1";
   case 10080:   return "W1";
   case 43200:   return "Mn1";
   
   }
   
   
   }
   
   

long ChartCheckAndOpen(string DesiredSymbol,int DesiredTF)
{
/*
bool ChartExist=0;
long currChart,prevChart=ChartFirst(); 
int i=0,limit=100;
while(i<limit)// у нас наверняка не больше 100 открытых графиков 
     { 
      currChart=ChartNext(prevChart); // на основании предыдущего получим новый график 
      if(currChart<0) break;          // достигли конца списка графиков 
      //Print(ChartSymbol(currChart)," ",currChart);
      if(ChartSymbol(currChart)==DesiredSymbol && ChartPeriod(currChart)==DesiredTF && ChartID()!=currChart){ChartExist=1;return currChart;}
      prevChart=currChart;// запомним идентификатор текущего графика для ChartNext() 
      i++;// не забудем увеличить счетчик 
     }
     
if(!ChartExist)
*/
return ChartOpen(DesiredSymbol,DesiredTF);
return -1;
}
