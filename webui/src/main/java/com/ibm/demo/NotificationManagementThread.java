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

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.stream.Collectors;

public class NotificationManagementThread extends Thread
{
    public static int latestNotification=0;
    public void run()
	{
        long wokenTime = System.currentTimeMillis();
		while(true)
		{
			try
            {
                System.out.println(System.currentTimeMillis()+" NotificationManagementThread BEFORE SLEEP while loop");
                long timeToSleep = 5000 -(System.currentTimeMillis()-wokenTime);
                if(timeToSleep>0)
                {
                    Thread.sleep(timeToSleep);
                }
                else
                {
                    System.out.println("WARNING: Notification Management thread took: " + (System.currentTimeMillis()-wokenTime)+"ms");
                }
                System.out.println(System.currentTimeMillis()+" NotificationManagementThread AWAKE while loop");
                wokenTime = System.currentTimeMillis();
                String noOfNotifications = getNotifications();
                latestNotification = Integer.parseInt(noOfNotifications);
                System.out.println(System.currentTimeMillis()+" NotificationManagementThread EXIT while loop");
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
		}
	}

    public static String getNotifications() throws Exception
	{
		URL url = new URL("http://notification-is:7800/count");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.connect();
            
        if(con.getResponseCode()==200)
        {        
            InputStream is = con.getInputStream();
			String result = new BufferedReader(new InputStreamReader(is)).lines().collect(Collectors.joining("\n"));
			System.out.println("Result from notification service="+result);
			if(result!=null)
			{
				int lastQuote = result.lastIndexOf("\"}");
				result = result.substring(0, lastQuote);
				lastQuote = result.lastIndexOf("\"")+1;
				result = result.substring(lastQuote);
				System.out.println("Actually returning: "+result);
			}
			is.close();
			return result;
		}
		return null;
        
	}
}