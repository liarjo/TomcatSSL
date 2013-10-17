<%@page import="java.net.InetAddress"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Hola Mundo V2 JSP</title>
</head>
<body>
	<%
	java.net.InetAddress ip = java.net.InetAddress.getLocalHost();
	ip = InetAddress.getLocalHost();
	System.out.println("Current Server IP address : " + ip.getHostAddress());
	String hostName=request.getServerName();
	String x=(String)session.getId();
	if ( x  == null ) {
			x="";
		}
    Integer count = (Integer)session.getAttribute("COUNT");
	// If COUNT is not found, create it and add it to the session
    if ( count == null ) {
      count = new Integer(1);
      session.setAttribute("COUNT", count);
    }
    else {
      count = new Integer(count.intValue() + 1);
      session.setAttribute("COUNT", count);
    }  
	%>
	<br>IP TOMCAT Server: <b><%=ip.getHostAddress() %></b><br>
	Cloud Services: <b><%=hostName%></b>
	<br>
	Session ID: <B><%=x  %></B>
	<br>Session Counter: <b><%=count%></B> times.
	
	<script language="JavaScript">
		var req = new XMLHttpRequest();
		req.open('GET', document.location + 'lala.jps', false);
		req.send(null);
		var headers = req.getAllResponseHeaders().toLowerCase();
		document.write('<p><b>HTTP Headers</b>: '  + headers);
	</script>
	
	<%
	   Cookie cookie = null;
	   Cookie[] cookies = null;
	   // Get an array of Cookies associated with this domain
	   cookies = request.getCookies();
	   if( cookies != null ){
	      out.println("<h2> Found Cookies Name and Value</h2>");
	      for (int i = 0; i < cookies.length; i++){
	         cookie = cookies[i];
	         out.print("Name : " + cookie.getName( ) + ",  ");
	         out.print("Value: " + cookie.getValue( )+" <br/>");
	      }
	  }else{
	      out.println("<h2>No cookies founds</h2>");
	  }
%>
</body>
</html>