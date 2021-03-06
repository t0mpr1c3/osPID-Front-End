void AdvanceData()
{
  // add the latest data to the data Arrays.  
  if ((millis() > nextRefresh) && portOpen)
  {
    nextRefresh  = millis() + refreshRate;
    
    if (!madeContact)
    {
      // try to establish connection
      // send a request for osPID type
      Msg m = new Msg(Token.IDENTIFY, NO_ARGS, true);
      if (!m.queue(msgQueue))
      {
        throw new NullPointerException("Invalid command: " + Token.IDENTIFY);
      }
      sendAll(msgQueue, myPort);
      return;
    }

    for (int i = nPoints - 1; i > 0; i--)
    {
      InputData[i] = InputData[i - 1];
      SetpointData[i] = SetpointData[i - 1];
      OutputData[i] = OutputData[i - 1];
    }
    if (nPoints < arrayLength) 
    {
      nPoints++;
    }

    InputData[0] = Input + calibration;
    SetpointData[0] = Setpoint;
    OutputData[0] = Output;
    
    if (!(currentxferStep > 0)) // pause updates if transferring profile data
    {
      // Query microcontroller for updates
      Msg m = new Msg(Token.QUERY, NO_ARGS, true);
      if (!m.queue(msgQueue))
      {
        throw new NullPointerException("Invalid command: " + Token.QUERY);
      }
      sendAll(msgQueue, myPort);
    }
  }  
}


void drawGraph()
{
  // draw Base, gridlines
  stroke(0);
  fill(230);
  rect(ioLeft, inputTop, ioWidth - 1 , inputHeight);
  rect(ioLeft, outputTop, ioWidth - 1, outputHeight);
  stroke(210);

  // Section Titles
  textFont(TitleFont);
  fill(255);
  text("PID Input / Setpoint", (int) ioLeft + 10, (int) inputTop - 5);
  text("PID Output", (int) ioLeft + 10, (int) outputTop - 5);

  if (!madeContact) 
  {
    return;
  }

  // GridLines and Titles
  textFont(AxisFont);

  // horizontal grid lines
  int interval = (int) inputHeight / 5;
  for (int i = 0; i < 6; i++)
  {
    if ((i > 0) && (i < 5))
    {
      line(ioLeft + 1, inputTop + i * interval, ioRight - 2, inputTop + i * interval);
    }
    text(str((InScaleMax - InScaleMin) / 5 * (float)(5 - i) + InScaleMin), ioRight + 5, inputTop + i * interval + 4);
  }
  interval = (int) outputHeight / 5;
  for (int i = 0; i < 6; i++)
  {
    if ((i > 0) && (i < 5)) 
    {
      line(ioLeft + 1, outputTop + i * interval, ioRight - 2, outputTop + i * interval);
    }
    text(str((OutScaleMax - OutScaleMin) / 5 * (float)(5 - i) + OutScaleMin), ioRight + 5, outputTop + i * interval + 4);
  }
  
  // red lines for alarm lower and upper temperature limits 
  int Y1, Y2; 
  if (alarmOn)
  {
    stroke(255, 0, 0);
    if ((tripLowerLimit >= InScaleMin) && (tripLowerLimit <= InScaleMax))
    {
      Y1 = int(inputHeight) - int(inputHeight * (tripLowerLimit - InScaleMin) / (InScaleMax - InScaleMin)) + int(inputTop);
      line(ioLeft + 1, Y1, ioRight - 2, Y1);
    }
    if ((tripUpperLimit >= InScaleMin) && (tripUpperLimit <= InScaleMax))
    {
      Y2 = int(inputHeight) - int(inputHeight * (tripUpperLimit - InScaleMin) / (InScaleMax - InScaleMin)) + int(inputTop);
      line(ioLeft + 1, Y2, ioRight - 2, Y2);
    }
  }
  stroke(0);

  // vertical grid lines and TimeStamps
  long elapsedTime = millis() - startTime;
  interval = (int)ioWidth / vertCount;
  int shift = (int)elapsedTime * (int)ioWidth / windowSpan;
  shift %= interval;

  int iTimeInterval = windowSpan/vertCount;
  float firstDisplay = (float)(iTimeInterval * (elapsedTime / iTimeInterval)) / displayFactor;
  float timeInterval = (float)(iTimeInterval) / displayFactor;
  for (int i = 0; i < vertCount; i++)
  {
    int x = (int) ioRight - shift - 2 - i * interval;

    line(x, inputTop + 1, x, inputTop + inputHeight - 1);
    line(x, outputTop + 1, x, outputTop + outputHeight - 1);    

    float t = firstDisplay - (float) i * timeInterval;
    if (t >= 0)  
    {
      text(str(t), x, outputTop + outputHeight + 10);
    }
  }

  
  AdvanceData();
  
  // draw lines for the input, setpoint, and output
  strokeWeight(4);
  for (int i = 0; i < nPoints - 2; i++)
  {
    int X1 = int(ioRight - 2 - float(i) * pointWidth);
    int X2 = int(ioRight - 2 - float(i + 1) * pointWidth);
    boolean y1Above, y1Below, y2Above, y2Below;


    // DRAW THE INPUT
    boolean drawLine = true;
    stroke(255, 0, 0);
    Y1 = int(inputHeight) - int(inputHeight * (InputData[i] - InScaleMin) / (InScaleMax - InScaleMin)); //InputData[i];
    Y2 = int(inputHeight) - int(inputHeight * (InputData[i + 1] - InScaleMin) / (InScaleMax - InScaleMin)); //InputData[i+1];

    y1Above = (Y1>inputHeight);                     // if both points are outside 
    y1Below = (Y1<0);                               // the min or max, don't draw the 
    y2Above = (Y2>inputHeight);                     // line.  if only one point is 
    y2Below = (Y2<0);                               // outside constrain it to the limit, 
    if(y1Above)                                     // and leave the other one untouched.
    {                                               //
      if(y2Above)                                   //
        drawLine=false;                             //
      else if(y2Below)                              //
      {                                             //
        Y1 = (int)inputHeight;                      //
        Y2 = 0;                                     //
      }                                             //
      else Y1 = (int)inputHeight;                   //
    }                                               //
    else if(y1Below)                                //
    {                                               //
      if(y2Below)                                   //
        drawLine=false;                             //
      else if(y2Above)                              //
      {                                             //
        Y1 = 0;                                     //
        Y2 = (int)inputHeight;                      //
      }                                             //
      else Y1 = 0;                                  //
    }                                               //
    else                                            //
    {                                               //
      if(y2Below)                                   //
        Y2 = 0;                                     //
      else if(y2Above)                              //
        Y2 = (int)inputHeight;                      //
    }                                               //

    if (drawLine)
    {
      line(X1, Y1 + inputTop, X2, Y2 + inputTop);
    }

    // DRAW THE SETPOINT
    drawLine = true;
    stroke(0, 255, 0);
    Y1 = int(inputHeight) - int(inputHeight * (SetpointData[i] - InScaleMin) / (InScaleMax - InScaleMin));// SetpointData[i];
    Y2 = int(inputHeight) - int(inputHeight * (SetpointData[i + 1] - InScaleMin) / (InScaleMax - InScaleMin)); //SetpointData[i+1];

    y1Above = (Y1>(int)inputHeight);                // if both points are outside 
    y1Below = (Y1<0);                               // the min or max, don't draw the 
    y2Above = (Y2>(int)inputHeight);                // line.  if only one point is 
    y2Below = (Y2<0);                               // outside constrain it to the limit, 
    if(y1Above)                                     // and leave the other one untouched.
    {                                               //
      if(y2Above)                                   //
        drawLine=false;                             //
      else if(y2Below)                              //
      {                                             //
        Y1 = (int)(inputHeight);                    //
        Y2 = 0;                                     //
      }                                             //
      else Y1 = (int)(inputHeight);                 //
    }                                               //
    else if(y1Below)                                //
    {                                               //
      if(y2Below)                                   //
        drawLine=false;                             //
      else if(y2Above)                              //
      {                                             //
        Y1 = 0;                                     //
        Y2 = (int)(inputHeight);                    //
      }                                             //
      else Y1 = 0;                                  //
    }                                               //
    else                                            //
    {                                               //
      if(y2Below)                                   //  
        Y2 = 0;                                     //
      else if(y2Above)                              //
        Y2 = (int)(inputHeight);                    //
    }                                               //

    if (drawLine)
    {
      line(X1, Y1 + inputTop, X2, Y2 + inputTop);
    }

    // DRAW THE OUTPUT
    drawLine = true;
    stroke(0, 0, 255);
    Y1 = int(outputHeight) - int(outputHeight * (OutputData[i] - OutScaleMin) / (OutScaleMax - OutScaleMin));// OutputData[i];
    Y2 = int(outputHeight) - int(outputHeight * (OutputData[i + 1] - OutScaleMin) / (OutScaleMax - OutScaleMin));//OutputData[i+1];

    y1Above = (Y1>outputHeight);                   // if both points are outside 
    y1Below = (Y1<0);                              // the min or max, don't draw the 
    y2Above = (Y2>outputHeight);                   // line.  if only one point is 
    y2Below = (Y2<0);                              // outside constrain it to the limit, 
    if(y1Above)                                    // and leave the other one untouched.
    {                                              //
      if(y2Above)                                  //
        drawLine=false;                            //
      else if(y2Below)                             //
      {                                            //
        Y1 = (int)outputHeight;                    //
        Y2 = 0;                                    //
      }                                            //
      else Y1 = (int)outputHeight;                 //
    }                                              //
    else if(y1Below)                               //
    {                                              //
      if(y2Below) drawLine=false;                  //
      else if(y2Above)                             //
      {                                            //
        Y1 = 0;                                    //
        Y2 = (int)outputHeight;                    //
      }                                            //  
      else Y1 = 0;                                 //
    }                                              //
    else                                           //
    {                                              //
      if(y2Below)                                  //
        Y2 = 0;                                    //
      else if(y2Above)                             //
        Y2 = (int)outputHeight;                    //
    }                                              //

    if (drawLine)
    {
      line(X1, outputTop + Y1, X2, outputTop + Y2);
    }
  }
  strokeWeight(1);
}
