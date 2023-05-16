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

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class SummaryOfResults 
{
	int requestsMade = 0;
	int responsesReceived = 0;
	int notMatchingQueueManager=0;
	int notMatchingIntegrationServer=0;
	Map<String, Integer> queueManagerRequests = new HashMap<String, Integer>();
	Map<String, Integer> queueManagerResponse = new HashMap<String, Integer>();
	public static Map<String, String> queueManagerVersion = new HashMap<String, String>();
	Map<String, Integer> integrationServers = new HashMap<String, Integer>();
	Map<String, Integer> echoServers = new HashMap<String, Integer>();
	int latestNotification=0;
	long totalDuration = 0;
	public static final String UNKNOWN = "unknown";
	static 
    {
        queueManagerVersion.put("ucqm1", UNKNOWN);
        queueManagerVersion.put("ucqm2", UNKNOWN);
        queueManagerVersion.put("ucqm3", UNKNOWN);
    }

	public int getRequestsMade() 
	{
		return requestsMade;
	}
	
	public void setRequestsMade(int requestsMade) 
	{
		this.requestsMade = requestsMade;
	}
	
	public int getResponsesReceived() 
	{
		return responsesReceived;
	}
	
	public void setResponsesReceived(int responsesReceived) 
	{
		this.responsesReceived = responsesReceived;
	}
	
	public Map<String, Integer> getQueueManagerRequests() 
	{
		return queueManagerRequests;
	}
	
	public void setQueueManagerRequests(Map<String, Integer> queueManagerRequests) 
	{
		this.queueManagerRequests = queueManagerRequests;
	}
	
	public Map<String, Integer> getQueueManagerResponse() 
	{
		return queueManagerResponse;
	}
	
	public void setQueueManagerResponse(Map<String, Integer> queueManagerResponse) 
	{
		this.queueManagerResponse = queueManagerResponse;
	}
	
	public Map<String, Integer> getIntegrationServers() 
	{
		return integrationServers;
	}
	
	public void setIntegrationServers(Map<String, Integer> integrationServers) 
	{
		this.integrationServers = integrationServers;
	}
	
	public Map<String, Integer> getEchoServers() 
	{
		return echoServers;
	}
	
	public void setEchoServers(Map<String, Integer> echoServers) 
	{
		this.echoServers = echoServers;
	}
	
	public void processResult(RunResults result)
	{
		if(result!=null)
		{
			requestsMade++;
			responsesReceived++;
			totalDuration += result.getDuration();
			if(!result.integrationServersTheSame())
			{
				notMatchingIntegrationServer++;
			}
			if(!result.queueManagersTheSame())
			{
				notMatchingQueueManager++;
			}
			
			String is = result.getIntegrationServer();
			if(!integrationServers.containsKey(is))
			{
				integrationServers.put(is, Integer.valueOf(0));
			}
			integrationServers.put(is, (integrationServers.get(is).intValue() +1));
			
			String qmgrRequest = result.getRequestQueueManager();
			if(!queueManagerRequests.containsKey(qmgrRequest))
			{
				queueManagerRequests.put(qmgrRequest, Integer.valueOf(0));
			}
			queueManagerRequests.put(qmgrRequest, (queueManagerRequests.get(qmgrRequest).intValue() +1));
						
			String qmgrResponse = result.getResponseQueueManager();
			if(!queueManagerResponse.containsKey(qmgrResponse))
			{
				queueManagerResponse.put(qmgrResponse, Integer.valueOf(0));
			}
			queueManagerResponse.put(qmgrResponse, (queueManagerResponse.get(qmgrResponse).intValue() +1));
			
			String backendIS = result.getBackendIntegrationServer();
			if(!echoServers.containsKey(backendIS))
			{
				echoServers.put(backendIS, Integer.valueOf(0));
			}
			echoServers.put(backendIS, (echoServers.get(backendIS).intValue() +1));
		}
	}
	
	public void processNotificationCalls()
	{
		try
		{
			
			latestNotification=NotificationManagementThread.latestNotification;
		}
		catch(Exception e)
		{
			latestNotification=0;
		}
	}

	public String toString()
	{
		StringBuffer buffer = new StringBuffer();
		if(notMatchingIntegrationServer!=0 || notMatchingQueueManager!=0)
		{
			buffer.append("**************************************** NotMatchingIntegrationServer="+notMatchingIntegrationServer+ " notMatchingQueueManager="+notMatchingQueueManager);
		}
		if(requestsMade>0)
		{
			buffer.append("Requests made: "+requestsMade + " with TotalDuration: "+totalDuration+ " average: "+totalDuration/requestsMade+"ms"+System.lineSeparator());
		}
		buffer.append("Queue Manager Request Summary="+queueManagerRequests+System.lineSeparator());
		buffer.append("Queue Manager Response Summary="+queueManagerResponse+System.lineSeparator());
		buffer.append("Integration Summary="+integrationServers+System.lineSeparator());
		buffer.append("EchoService Summary="+echoServers+System.lineSeparator());
		buffer.append("Notification Summary="+latestNotification+System.lineSeparator());
		return buffer.toString();
	}
	
	public String toJson()
	{
		synchronized (this) 
		{
			StringBuffer buffer = new StringBuffer();		
			buffer.append("{"+System.lineSeparator()+"   \"totalRequests\": "+requestsMade+","+System.lineSeparator());
			buffer.append("   \"queueManagers\": ["+System.lineSeparator());
			Iterator<String> queueManagerNameIterator = queueManagerRequests.keySet().iterator();
			while(queueManagerNameIterator!=null && queueManagerNameIterator.hasNext())
			{
				String qmgrName = queueManagerNameIterator.next();
				buffer.append("      {"+System.lineSeparator());
				buffer.append("         \"name\": \""+qmgrName+"\","+System.lineSeparator());
				buffer.append("         \"version\": \""+queueManagerVersion.get(qmgrName)+"\","+System.lineSeparator());
				buffer.append("         \"requests\": "+queueManagerRequests.get(qmgrName)+","+System.lineSeparator());
				buffer.append("         \"response\": "+queueManagerResponse.get(qmgrName)+System.lineSeparator());
				if(queueManagerNameIterator.hasNext())
				{
					buffer.append("      },"+System.lineSeparator());
				}
				else
				{
					buffer.append("      }"+System.lineSeparator());
					buffer.append("   ],"+System.lineSeparator());
				}
			}
			
			buffer.append("   \"integrationServers\": ["+System.lineSeparator());
			Iterator<String> integrationServersIterator = integrationServers.keySet().iterator();
			while(integrationServersIterator!=null && integrationServersIterator.hasNext())
			{
				String isName = integrationServersIterator.next();
				buffer.append("      {"+System.lineSeparator());
				buffer.append("         \"name\": \""+isName+"\","+System.lineSeparator());
				buffer.append("         \"requests\": "+integrationServers.get(isName)+System.lineSeparator());
				if(integrationServersIterator.hasNext())
				{
					buffer.append("      },"+System.lineSeparator());
				}
				else
				{
					buffer.append("      }"+System.lineSeparator());
					buffer.append("   ],"+System.lineSeparator());
				}
			}
			
			buffer.append("   \"echoServer\": ["+System.lineSeparator());
			Iterator<String> echoServerIterator = echoServers.keySet().iterator();
			while(echoServerIterator!=null && echoServerIterator.hasNext())
			{
				String echoName = echoServerIterator.next();
				buffer.append("      {"+System.lineSeparator());
				buffer.append("         \"name\": \""+echoName+"\","+System.lineSeparator());
				buffer.append("         \"requests\": "+echoServers.get(echoName)+System.lineSeparator());
				if(echoServerIterator.hasNext())
				{
					buffer.append("      },"+System.lineSeparator());
				}
				else
				{
					buffer.append("      }"+System.lineSeparator());
					buffer.append("   ],"+System.lineSeparator());
				}
			}
			
			
			buffer.append("   \"notificationCalls\": \""+latestNotification+"\""+System.lineSeparator());
			buffer.append("}"+System.lineSeparator());
			return buffer.toString();
		}
	}
	
}
