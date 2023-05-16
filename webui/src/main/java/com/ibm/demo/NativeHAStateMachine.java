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

public class NativeHAStateMachine 
{
    long changeTime;
    String originalVersion;
    String newVersion;

    int runningContainers=3;
    int containersUpgraded=0;
    //boolean justStartedUpgrade=true;

    
    public NativeHAStateMachine(long changeTime, String originalVersion, String newVersion) 
    {
        this.changeTime = changeTime;
        this.originalVersion = originalVersion;
        this.newVersion = newVersion;
    }

    public void numberOfContainerRunning(int runningContainers)
    {
        if(this.runningContainers!=runningContainers)
        {
            if(runningContainers!=3)
            {
                // Means container being upgraded
                if(containersUpgraded<3)
                {
                    containersUpgraded++;
                }
                this.runningContainers=runningContainers;
            }
            else
            {
                this.runningContainers=runningContainers;
            }
        }
    }

    public boolean isUpgradeComplete()
    {
        if(containersUpgraded>=3)
        {
            return true;
        }
        return false;
    }
    public long getChangeTime() 
    {
        return changeTime;
    }
    public void setChangeTime(long changeTime) 
    {
        this.changeTime = changeTime;
    }
    public String getOriginalVersion() 
    {
        return originalVersion;
    }
    public void setOriginalVersion(String originalVersion) 
    {
        this.originalVersion = originalVersion;
    }
    public String getNewVersion() 
    {
        return newVersion;
    }
    public void setNewVersion(String newVersion) 
    {
        this.newVersion = newVersion;
    }
    public String toString()
    {
        return newVersion +" upgrading...."+containersUpgraded+"/3";
    }        
}
