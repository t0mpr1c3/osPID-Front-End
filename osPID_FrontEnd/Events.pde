void sendCmd(Token token, String[] args)
{
  Msg m = new Msg(token, args);
  if (!m.queue(msgQueue))
    throw new NullPointerException("Invalid command");
  String cmd = token.symbol + " " + join(args, " ");
  //updateDashStatus(cmd);
  // return true;
  
  sendAll(msgQueue, myPort);
  
  
  
  ListIterator m1 = msgQueue.listIterator();
  String c1;
  int i1 = 0;
  while (m1.hasNext() && i1 < 6)
  {
    Msg nextMsg1 = (Msg)m1.next();
    c1 = nextMsg1.getToken().symbol + " " + join(nextMsg1.getArgs(), " ");
    if (nextMsg1.sent())
      c1 = c1 + "s";
    else if (nextMsg1.markedReadyToSend())
      c1=c1 + "r";
    else  if (nextMsg1.queued())
      c1=c1 + "q";
    ((controlP5.Textlabel)controlP5.controller("dashstat" + i1)).setStringValue(c1);
    i1++;
  }
  for (int i2=i1;i2<6;i2++)
  {
   ((controlP5.Textlabel)controlP5.controller("dashstat" + i2)).setStringValue("");
  } 
  
}

void sendCmdFloat(Token token, String theText, int decimals)
{
  String[] args = {""};
  try
  {
    args[0] = nf(Float.valueOf(theText).floatValue(), 0, decimals);
  }
  catch(NumberFormatException ex)
  {
    // updateDashStatus("Input error");
    return; // return false;
  }
  sendCmd(token, args);
}

void sendCmdInteger(Token token, int value)
{
  String[] args = {""};
  try
  {
    args[0] = nf(value, 0, 0);
  }
  catch(NumberFormatException ex)
  {
    // updateDashStatus("Input error");
    return; // return false;
  }
  sendCmd(token, args);
}

void Set_Value(String theText)
{
  sendCmdFloat(Token.SET_VALUE, theText, 1);
}

void Process_Value(String theText)
{
  // do nothing, even if we get here
}

void Output(String theText)
{
  // send output (only makes sense in manual mode)
  sendCmdFloat(Token.OUTPUT, theText, 1);
}

void Auto_Manual() 
{
  if(AMButton.getCaptionLabel().getText() == "Set PID Control") 
  {
    AMLabel.setValue("PID Control");        
    AMButton.setCaptionLabel("Set Manual Control");  
    sendCmdInteger(Token.AUTO_CONTROL, 1);
  }
  else
  {
    AMLabel.setValue("Manual Control");   
    AMButton.setCaptionLabel("Set PID Control");  
    sendCmdInteger(Token.AUTO_CONTROL, 0);
  }
}

void Alarm_Enable() 
{
  if(AlarmEnableButton.getCaptionLabel().getText() == "Set Alarm Off") 
  {
    AlarmEnableLabel.setValue("Alarm OFF");  
    AlarmEnableButton.setCaptionLabel("Set Alarm On"); 
    sendCmdInteger(Token.ALARM_ON, 0);
  }
  else
  {
    AlarmEnableLabel.setValue("Alarm ON");     
    AlarmEnableButton.setCaptionLabel("Set Alarm Off"); 
    sendCmdInteger(Token.ALARM_ON, 1);
  }
}

void Alarm_Min(String theText)
{
  sendCmdFloat(Token.ALARM_MIN, theText, 1);
}

void Alarm_Max(String theText)
{
  sendCmdFloat(Token.ALARM_MAX, theText, 1);
}

void Alarm_Reset() 
{
  if(AutoResetButton.getCaptionLabel().getText() == "Set Manual Reset") 
  {
    AutoResetLabel.setValue("Manual Reset");
    AutoResetButton.setCaptionLabel("Set Auto Reset"); 
    sendCmdInteger(Token.ALARM_AUTO_RESET, 0);
  }
  else
  {
    AutoResetLabel.setValue("Auto Reset");  
    AutoResetButton.setCaptionLabel("Set Manual Reset"); 
    sendCmdInteger(Token.ALARM_AUTO_RESET, 1);
  }
}

void Kp(String theText)
{
  sendCmdFloat(Token.KP, theText, 3);
}

void Ki(String theText)
{
  sendCmdFloat(Token.KI, theText, 3);
}

void Kd(String theText)
{
  sendCmdFloat(Token.KD, theText, 3);
}

void Direct_Reverse() 
{
  if(DRButton.getCaptionLabel().getText()== "Set Reverse Action") 
  {
    DRLabel.setValue("Reverse Action");  
    DRButton.setCaptionLabel("Set Direct Action"); 
    sendCmdInteger(Token.REVERSE_ACTION, 1);
  }
  else
  {
    DRLabel.setValue("Direct Action");     
    DRButton.setCaptionLabel("Set Reverse Action"); 
    sendCmdInteger(Token.REVERSE_ACTION, 0);
  }
}

void AutoTune_On_Off() 
{
  if(ATButton.getCaptionLabel().getText() == "Set Auto Tune Off") 
  {
    ATLabel.setValue("Auto Tune OFF");
    ATButton.setCaptionLabel("Set Auto Tune On");  
    sendCmdInteger(Token.AUTO_TUNE_ON, 0);
  }
  else
  {
    ATLabel.setValue("Auto Tune ON");   
    ATButton.setCaptionLabel("Set Auto Tune Off");
    sendCmdInteger(Token.AUTO_TUNE_ON, 1);
  }
}

void Output_Step(String theText)
{  
  String[] args = {""};
  Float n;
  try
  {
    n = Float.valueOf(theText).floatValue();
    args[0] = nf(n, 0, 1);
    args[1] = nf(Float.valueOf(nLabel.getStringValue()).floatValue(), 0, 1);
    args[2] = nf(Float.valueOf(lbLabel.getStringValue()).floatValue(), 0, 0);
  }
  catch(NumberFormatException ex)
  {
    // updateDashStatus("Input error");
    return; // return false;
  }
  //oSLabel.setValue(nf(n, 0, 1)); // must wait for acknowledgment
  sendCmd(Token.AUTO_TUNE_PARAMETERS, args);
}

void Noise_Band(String theText)
{  
  String cmd;
  Float n;
  try
  {
    n = Float.valueOf(theText).floatValue();
    args[0] = nf(Float.valueOf(oSLabel.getStringValue()).floatValue(), 0, 1); 
    args[1] = nf(n, 0, 1);
    args[2] = nf(Float.valueOf(lbLabel.getStringValue()).floatValue(), 0, 0);
  }
  catch(NumberFormatException ex)
  {
    // updateDashStatus("Input error");
    return; // return false;
  }
  //nLabel.setValue(nf(n, 0, 1)); // must wait for acknowledgment
  sendCmd(Token.AUTO_TUNE_PARAMETERS, args);
}

void Look_Back(String theText)
{  
  String cmd;
  Float n;
  try
  {
    n = Float.valueOf(theText).floatValue();
    args[0] = nf(Float.valueOf(oSLabel.getStringValue()).floatValue(), 0, 1); 
    args[1] = nf(Float.valueOf(nLabel.getStringValue()).floatValue(), 0, 1);
    args[2] = nf(n, 0, 1);
  }
  catch(NumberFormatException ex)
  {
    // updateDashStatus("Input error");
    return; // return false;
  }
  //lbLabel.setValue(nf(n, 0, 0)); // must wait for acknowledgment
  sendCmd(Token.AUTO_TUNE_PARAMETERS, args);
}

void updateDashStatus(String update)
{
  if (dashStatus < 5)
  {
    ((controlP5.Textlabel)controlP5.controller("dashstat" + dashStatus)).setValue(update);
    dashStatus++;
  }
  else
  {
    for (int i = 0; i < 5; i++)
    {
      ((controlP5.Textlabel)controlP5.controller("dashstat" + i)).setValue(
        ((controlP5.Textlabel)controlP5.controller("dashstat" + i + 1)).getStringValue() // fails
      );
    }
    ((controlP5.Textlabel)controlP5.controller("dashstat5")).setValue(update);
  }
}
    
      












