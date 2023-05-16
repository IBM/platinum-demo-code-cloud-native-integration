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

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Arrays;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

public class CallAPI 
{
	private static final String inputData = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Path><runtime>runtime</runtime></Path>";
	
	public static RunResults callAPI()
	{
		URL url;
		int retries=0;
		while(retries<3)
		{
			try {
				//System.out.print("Calling");
				long startTime = System.currentTimeMillis();
				url = new URL("http://infinite-is:7800/infinitescale");
				HttpURLConnection con = (HttpURLConnection) url.openConnection();
				con.setRequestMethod("POST");
				con.setDoOutput(true);
				
				OutputStream os = con.getOutputStream();
				os.write(inputData.getBytes());
				os.flush();
				os.close();
				

				InputStream is = con.getInputStream();
				byte[] dataReceived = new byte[1024];
				int readBytes = is.read(dataReceived);
				long endTime = System.currentTimeMillis();
				RunResults result = RunResults.parseData(Arrays.copyOf(dataReceived, readBytes));
				result.setDuration((endTime-startTime));
				//System.out.println(Thread.currentThread().getName() + " " + result);
				con.disconnect();
				return result;
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				if(retries!=0)
				{
					System.out.println("Retry count="+retries);
					e.printStackTrace();
				}
					
			} catch (ParserConfigurationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SAXException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			retries++;
		}
		return null;
	}
}
