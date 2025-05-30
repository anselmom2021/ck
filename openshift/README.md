> [!IMPORTANT]  
> **This `README.md` file intends to be a guide regarding how to use this repo - Project ModRS EDGE**

# Structure

The repository is composed of several folders, each dedicated to a specific topic:

#  - SentinelOne

    This repository stores the scripts related to the integration between OpenShift clusters (Hub or Stations) and the SentinelOne platform.

    These scripts deploy a single container on each cluster node to monitor all inbound and outbound traffic. The collected data is then sent to SentinelOne.

    For more information about the deployment process and/or the integration with GitOps, contact @Christian Lyngsmo / @Mervyn Roman.

#  - OKTA

    This repository stores the scripts related to the integration between OpenShift clusters (Hub or Stations) and the Okta platform.

    These scripts enable OpenShift authentication integration with Okta, implementing Role-Based Access Control (RBAC) based on Active Directory (AD) groups. Once set up, AD groups must be defined per role-based function and linked within OpenShift, allowing granular control over operations and user privileges. 

    For more information about the deployment process and/or the integration with GitOps, contact @Christian Lyngsmo / @Mervyn Roman.