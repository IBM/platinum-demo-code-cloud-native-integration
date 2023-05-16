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
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class InvokePipeline implements HttpHandler
{
	private String pipelineID;
	
	public InvokePipeline(String pipelineID) 
	{
		super();
		this.pipelineID = pipelineID;
	}

	@Override
	public void handle(HttpExchange exchange) throws IOException 
	{
		if(pipelineID.equals("notification"))
		{
			startupNotificationService();
		}
		String urlString="http://el-infinite-base-pipeline-event-listener:8080";
		                    
		System.out.println("urlString="+urlString);
		URL url=new URL(urlString);

		HttpURLConnection con = (HttpURLConnection) url.openConnection();
		con.setDoOutput(true);
		con.setDoInput(true);
		con.setRequestProperty("Content-Type", "application/json");
		con.setRequestProperty("Accept", "application/json");
		con.setRequestMethod("POST");
		
		con.getOutputStream().write(("{\"branch\": \""+pipelineID+"\"}").getBytes());
		
		
		StringBuffer sb = new StringBuffer();
		int httpResult = con.getResponseCode(); 
		if (httpResult == HttpURLConnection.HTTP_OK) {
		    BufferedReader br = new BufferedReader(
		            new InputStreamReader(con.getInputStream(), "utf-8"));
		    String line = null;  
		    while ((line = br.readLine()) != null) {  
		        sb.append(line + "\n");  
		    }
		    br.close();
		    System.out.println("" + sb.toString());  
		} else {
		    System.out.println(con.getResponseMessage());  
		}
		OutputStream os = exchange.getResponseBody();
        String response = "Success!";
        exchange.sendResponseHeaders(200, response.length());
        
        os.write(response.getBytes());
        os.close();
	}

	private void startupNotificationService() throws IOException 
	{
		String urlString="http://el-infinite-notification-pipeline-event-listener:8080";		                    
                                 
		System.out.println("urlString="+urlString);
		URL url=new URL(urlString);

		HttpURLConnection con = (HttpURLConnection) url.openConnection();
		con.setDoOutput(true);
		con.setDoInput(true);
		con.setRequestProperty("Content-Type", "application/json");
		con.setRequestProperty("Accept", "application/json");
		con.setRequestMethod("POST");
		
		con.getOutputStream().write(("{\"branch\": \""+pipelineID+"\"}").getBytes());
		
		
		StringBuffer sb = new StringBuffer();
		int httpResult = con.getResponseCode(); 
		if (httpResult == HttpURLConnection.HTTP_OK) {
		    BufferedReader br = new BufferedReader(
		            new InputStreamReader(con.getInputStream(), "utf-8"));
		    String line = null;  
		    while ((line = br.readLine()) != null) {  
		        sb.append(line + "\n");  
		    }
		    br.close();
		    System.out.println("" + sb.toString());  
		} else {
		    System.out.println(con.getResponseMessage());  
		}
		
	}

}
