/* © Copyright IBM Corporation 2023
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. */
package com.ibm.demo;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;

public class ManagementThread extends Thread
{
    private static final SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy.MM.dd.HH.mm.ss");

    public void run()
	{
        long wokenTime = System.currentTimeMillis();
		while(true)
		{
			try
            {
                long timeToSleep = 5000 -(System.currentTimeMillis()-wokenTime);
                if(timeToSleep>0)
                {
                    Thread.sleep(timeToSleep);
                }
                else
                {
                    System.out.println("WARNING: Management thread took: " + (System.currentTimeMillis()-wokenTime)+"ms");
                }
                wokenTime = System.currentTimeMillis();
                ArrayList<RunResults> oldList;
                System.out.println(System.currentTimeMillis()+" ManagementThread ENTRY StartTests.list");
                synchronized (StartTests.list) 
                {
                    System.out.println(System.currentTimeMillis()+" ManagementThread IN StartTests.list");
                    oldList = StartTests.list;
                    StartTests.list = new ArrayList<RunResults>();
                    System.out.println(System.currentTimeMillis()+" ManagementThread EXIT StartTests.list");
                }
                Iterator<RunResults> iteratorResults = oldList.iterator();
                System.out.println(System.currentTimeMillis()+" ManagementThread ENTRY StartTests.currentSummary");
                synchronized(StartTests.currentSummary)
                {
                    System.out.println(System.currentTimeMillis()+" ManagementThread IN StartTests.currentSummary");
                    StartTests.currentSummary = new SummaryOfResults();
                    while(iteratorResults.hasNext())
                    {
                        StartTests.currentSummary.processResult(iteratorResults.next());
                    }
                    StartTests.currentSummary.processNotificationCalls();
                    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
                    System.out.println(sdf1.format(timestamp));
                    System.out.println("Summary="+StartTests.currentSummary.toString());
                    oldList.clear();
                    System.out.println(System.currentTimeMillis()+" ManagementThread EXIT StartTests.currentSummary");
                }
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
		}
	}
}