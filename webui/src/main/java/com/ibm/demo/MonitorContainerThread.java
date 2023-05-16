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
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import com.jayway.jsonpath.DocumentContext;
import com.jayway.jsonpath.JsonPath;

public class MonitorContainerThread extends Thread
{
    static Map<String, NativeHAStateMachine> upgradedQMGRs = new HashMap<String, NativeHAStateMachine>();
    public void run()
	{
		while(true)
		{
			try
            {
                Thread.sleep(2000);
                SummaryOfResults.queueManagerVersion.put("ucqm1", updateMQVersions("ucqm1"));
                SummaryOfResults.queueManagerVersion.put("ucqm2", updateMQVersions("ucqm2"));
                SummaryOfResults.queueManagerVersion.put("ucqm3", updateMQVersions("ucqm3"));
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
		}
	}

    private String updateMQVersions(String qmgr) 
    {
        String existingVersion = SummaryOfResults.queueManagerVersion.get(qmgr);
        String apiServer = "https://kubernetes.default.svc";
        String serviceAccount = "/var/run/secrets/kubernetes.io/serviceaccount";
        String namespace = readFromFile(serviceAccount+"/namespace");
        String token = readFromFile(serviceAccount+"/token");

        TrustManager[] trustAllCerts = new TrustManager[]
        {
            new X509TrustManager() 
            {
                public java.security.cert.X509Certificate[] getAcceptedIssuers() 
                {
                    return null;
                }
                public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType) 
                {
                }
                public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType) 
                {
                }
            }
        };

        try
        {
            URL url = new URL(apiServer+"/apis/mq.ibm.com/v1beta1/namespaces/"+namespace+"/queuemanagers/"+qmgr);
            SSLContext sc = SSLContext.getInstance("SSL");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

            HttpsURLConnection con = (HttpsURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Authorization", "Bearer "+token);
            con.connect();
            
            if(con.getResponseCode()==200)
            {        
                InputStream is = con.getInputStream();
                DocumentContext docContext = JsonPath.parse(is);
                String version = docContext.read("$.status.versions.reconciled", String.class);
                if(!existingVersion.equals(SummaryOfResults.UNKNOWN) && !existingVersion.equals(version))
                {
                    if(!upgradedQMGRs.containsKey(qmgr))
                    {
                        upgradedQMGRs.put(qmgr, new NativeHAStateMachine(System.currentTimeMillis(), existingVersion, version));
                        return version +" upgrading...";
                    }
                    else
                    {
                        URL getPodsUrl = new URL(apiServer+"/api/v1/namespaces/"+namespace+"/pods?fieldSelector=status.phase%3DRunning&labelSelector=app.kubernetes.io%2Finstance%3D"+qmgr);
                        HttpsURLConnection getPodsCon = (HttpsURLConnection) getPodsUrl.openConnection();
                        getPodsCon.setRequestMethod("GET");
                        getPodsCon.setRequestProperty("Authorization", "Bearer "+token);
                        getPodsCon.connect();
                        if(getPodsCon.getResponseCode()==200)
                        {
                            InputStream getPodIS = getPodsCon.getInputStream();
                            DocumentContext getPodDocContext = JsonPath.parse(getPodIS);
                            //System.out.println(getPodDocContext.jsonString());
                            String podRunning = getPodDocContext.read("$.items.length()", String.class);
                            System.out.println("podRunning="+podRunning);
                            int runningContainers = Integer.parseInt(podRunning);
                            upgradedQMGRs.get(qmgr).numberOfContainerRunning(runningContainers);
                            if(upgradedQMGRs.get(qmgr).isUpgradeComplete())
                            {
                                upgradedQMGRs.remove(qmgr);
                                return version;
                            }
                            return upgradedQMGRs.get(qmgr).toString();
                        }
                    }

                    
                }
                return version;
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        return "unknown";
    }


    private String readFromFile(String fileName)
    {
      StringBuilder resultStringBuilder = new StringBuilder();
      try 
      {
        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(fileName)));
        String line;
        while ((line = br.readLine()) != null) 
        {
           resultStringBuilder.append(line);
        }
      }
      catch(IOException e)
      {
        e.printStackTrace();
      }
      return resultStringBuilder.toString();
    }

}