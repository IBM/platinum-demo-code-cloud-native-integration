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

import java.io.ByteArrayInputStream;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class RunResults 
{

	String requestFlowServer;
	String responseFlowServer;
	String backendServer;
	String requestQMGR;
	String responseQMGR;
	long duration;
	
	public RunResults(String requestFlowServer, String responseFlowServer, String backendServer, String requestQMGR, String responseQMGR) 
	{
		this.requestFlowServer = requestFlowServer;
		this.requestQMGR = requestQMGR;
		this.responseFlowServer = responseFlowServer;
		this.responseQMGR = responseQMGR;
		this.backendServer = backendServer;
	}
	
	public static RunResults parseData(byte[] xmlData) throws ParserConfigurationException, SAXException, IOException
	{
		ByteArrayInputStream input = new ByteArrayInputStream(xmlData);
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		Document doc = builder.parse(input);
		String requestFlowServer = doc.getDocumentElement().getChildNodes().item(1).getTextContent();
		requestFlowServer = requestFlowServer.substring(requestFlowServer.lastIndexOf(":")+2);
		
		String responseFlowServer = doc.getDocumentElement().getChildNodes().item(5).getTextContent();
		responseFlowServer = responseFlowServer.substring(responseFlowServer.lastIndexOf(":")+2);
		
		String backendServer = doc.getDocumentElement().getChildNodes().item(3).getTextContent(); 
		backendServer = backendServer.substring(backendServer.lastIndexOf(":")+2);
		
		String requestQMGR = doc.getDocumentElement().getChildNodes().item(2).getTextContent();
		requestQMGR = requestQMGR.substring(requestQMGR.lastIndexOf(":")+2);
		
		String responseQMGR = doc.getDocumentElement().getChildNodes().item(4).getTextContent();
		responseQMGR = responseQMGR.substring(responseQMGR.lastIndexOf(":")+2);

		
		return new RunResults(requestFlowServer, responseFlowServer, backendServer, requestQMGR, responseQMGR);
		
	}

	public boolean queueManagersTheSame()
	{
		return requestQMGR.equals(responseQMGR);
	}
	
	public boolean integrationServersTheSame()
	{
		return requestFlowServer.equals(responseFlowServer);
	}
	
	public long getDuration()
	{
		return duration;
	}

	public void setDuration(long duration)
	{
		this.duration = duration;
	}

	public String getIntegrationServer()
	{
		return requestFlowServer;
	}
	
	public String getRequestQueueManager()
	{
		return requestQMGR;
	}
	
	public String getResponseQueueManager()
	{
		return responseQMGR;
	}
	
	public String getBackendIntegrationServer()
	{
		return backendServer;
	}
	
	public String toString()
	{
		if(! responseQMGR.equals(requestQMGR))
		{
			return "QMGR DO NOT MATCH **********************************";
		}
		return "duration: "+ duration+"requestFlowServer: "+ requestFlowServer+ " responseFlowServer: "+ responseFlowServer + " backendServer: "+ backendServer+ " requestQMGR: " + requestQMGR + " responseQMGR: " + responseQMGR;
	}
}
