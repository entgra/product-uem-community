<%--
  ~ Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~  WSO2 Inc. licenses this file to you under the Apache License,
  ~  Version 2.0 (the "License"); you may not use this file except
  ~  in compliance with the License.
  ~  You may obtain a copy of the License at
  ~
  ~    http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
--%>

<!-- localize.jsp MUST already be included in the calling script -->

<%@ page import="org.apache.commons.lang.StringUtils"%>

<% if ("UEM Server".equals(request.getAttribute("headerTitle"))) { %>
<div class="product-title">
    <div class="theme-icon inline auto transparent product-logo">
        <img src=extensions/customAssets/logo.svg alt="Logo" />
      </div>
      <h1 class="product-title-text">UEM Server</h1>
</div>
<% } else {

    String logoSrc = (String)request.getAttribute("logoSrc");
    String logoHeight = (String)request.getAttribute("logoHeight");
    String logoWidth = (String)request.getAttribute("logoWidth");
    String logoAltText = (String)request.getAttribute("logoAltText");
    if (!StringUtils.isEmpty(logoSrc)) {
%>
        <div class="product-title box">
            <img src=<%=logoSrc%> alt=<%=logoAltText%> height=<%=logoHeight%> width=<%=logoWidth%>>
        </div>
<%  } else { %>
        <div class="product-title box">
            <h1 class="product-title-text" vertical-align="middle"><%=request.getAttribute("headerTitle")%></h1>
        </div>
<%  } %>
<% } %>
