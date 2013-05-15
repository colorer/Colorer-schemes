<%

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  Trying to retrieve the data from the request                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

  // preparing servlet link
  java.lang.String lservlet_link = "com.ibm.rsca.mm.frontend.display.DisplMMForm";
  java.lang.String lservlet_link2 = "com.ibm.rsca.mm.frontend.display.DisplMMListForm";
  java.lang.String llink_prefix = lservlet_link + "?W2J_TCODE=MM03";

  // getting list data
  java.util.Vector llist = (java.util.Vector)request.getAttribute("J2W_LIST");

  java.lang.Integer litems_total = (java.lang.Integer)request.getAttribute("J2W_ITEMS_TOTAL");
  java.lang.Integer litems_current = (java.lang.Integer)request.getAttribute("J2W_ITEMS_CURRENT");
  java.lang.Integer litems_per_page = (java.lang.Integer)request.getAttribute("J2W_ITEMS_PER_PAGE");

%><%

  tmpl_pg_content_top.reset();
  tmpl_pg_content_top.replace(marker_servlet,lservlet_link);

%><%= tmpl_pg_content_top.generate() %>

                  <%

                    tmpl_pg_section_header.reset();
                    int lcur_page = (litems_current.intValue())/(litems_per_page.intValue());                                                    
                    int lpages = (litems_total.intValue())/(litems_per_page.intValue());                                                    
                    java.lang.String lpageofpages = "Material Master Items (Page "+new java.lang.Integer(lcur_page+1).toString()+" of "+new java.lang.Integer(lpages+1).toString()+")";
//                    tmpl_pg_section_header.replace(marker_title,"Material Master Items (Page 12 of 35)");
                    tmpl_pg_section_header.replace(marker_title,lpageofpages);

                  %><%= tmpl_pg_section_header.generate() %>

                  <% 

                    java.lang.String lstr_list=new java.lang.String();
                                                             
                    if (lcur_page!=0) {
                      lstr_list = "[<a href=" + lservlet_link2 + "?W2J_ITEMS_STARTING="  + new java.lang.Integer((lcur_page-1)*(litems_per_page.intValue())+1).toString() + ">Previous</a>]";
                    }
                   if (litems_total.intValue()>((lcur_page+1)*litems_per_page.intValue())) {
                      lstr_list = lstr_list.concat("[<a href=" + lservlet_link2 + "?W2J_ITEMS_STARTING="  + new java.lang.Integer((lcur_page+1)*(litems_per_page.intValue())+1).toString() + ">Next</a>]");
                    }
                  %>

<center><%= lstr_list %></center>



                  <%= tmpl_ivdiv7px.generate() %>
<!--
                  <center>
                    Pages:
                    <a href="#">[&lt;&lt; Previous]</a>
                    <a href="#">11</a>
                    <b>12</b>
                    <a href="#">13</a>
                    <a href="#">14</a>
                    <a href="#">15</a>
                    <a href="#">16</a>
                    <a href="#">17</a>
                    <a href="#">18</a>
                    <a href="#">19</a>
                    <a href="#">[Next &gt;&gt;]</a><br>
                    <%= tmpl_ivdiv7px.generate() %>
                  </center>
-->

                  <style type="text/css">.rscathfnt{font-family:Verdana,sans-serif;font-size:13px;}</style>

                  <center><table width="100%" cellpadding="0" cellspacing="0" border="0">
                    <tr>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Plant<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Mfg. Line<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Material #<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Supp. #<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Supp. Name<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;Descr.<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td class="tdblue"><span class="rscathfnt"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br />&nbsp;&nbsp;<br><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></span></td>
                    </tr>
                    <!-- !!! Temporary Code For List Start !!! -->
                    <%

                        for(int i=0;i<llist.size();i++){

                          // getting main object and trying to split
                          com.ibm.rsca.objects.MM lMM = (com.ibm.rsca.objects.MM)llist.get(i);
                            com.ibm.rsca.objects.RscLine lRscLine = lMM.getTheRscLine();
                              com.ibm.rsca.objects.RscProvider lRscProvider = lRscLine.getTheRscProvider();
                            com.ibm.rsca.objects.SuppLineMat lSuppLineMat = lMM.getTheSuppLineMat();
                              com.ibm.rsca.objects.LineMat lLineMat = lSuppLineMat.getTheLineMat();
                                com.ibm.rsca.objects.PlantLine lPlantLine = lLineMat.getThePlantLine();
                                com.ibm.rsca.objects.Material lMaterial = lLineMat.getTheMaterial();
                              com.ibm.rsca.objects.Supplier lSupplier = lSuppLineMat.getTheSupplier();
                                com.ibm.rsca.objects.Address lAddress = lSupplier.getTheAddress();
                                com.ibm.rsca.objects.WWSupplierInfo lWWSupplierInfo = lSupplier.getTheWWSupplierInfo();

                          java.lang.String lPlant = new java.lang.String(lPlantLine.getPlantCode());
                          java.lang.String lMfgLine = new java.lang.String(lPlantLine.getPlantLineCode());
                          java.lang.String lMaterialNumber = new java.lang.String(lMaterial.getPartNum());
                          java.lang.String lSupplierNumber = new java.lang.String(lSupplier.getSupplierNum());
                          java.lang.String lSupplierName = new java.lang.String(lSupplier.getSupplierName());
                          java.lang.String lDescription = new java.lang.String(lMaterial.getPartDesc());                                              
  
                          java.lang.String lDetailsLink = llink_prefix + "&W2J_SUPP_LINE_MAT_OID=" + lSuppLineMat.getSuppLineMatOid().toString() + "&W2J_RSC_LINE_CODE=" + lRscLine.getRscLineCode();

                    %><tr><td cellpadding="0" colspan="13"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></td></tr>
                    <tr>
                      <td><span class="small">&nbsp;<%= lPlant %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<%= lMfgLine %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<%= lMaterialNumber %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<%= lSupplierNumber %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<%= lSupplierName %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<%= lDescription %></span></td>
                      <td width="1"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td>
                      <td><span class="small">&nbsp;<a href="<%= lDetailsLink %>">Details</a></span></td>
                    </tr>
                    <tr><td cellpadding="0" colspan="13"><img src="http://www.ibm.com/i/c.gif" width="1" height="3" alt=""/><br /></td></tr>
                    <tr><td bgcolor="#999999" cellpadding="0" colspan="13"><img src="http://www.ibm.com/i/c.gif" width="1" height="1" alt=""/><br /></td></tr><%

                      }

                    %>
                    <!-- !!! Temporary Code For List End !!! -->
                  </table></center>

<center><%= lstr_list %></center>
<!--                  <center>
                    <%= tmpl_ivdiv7px.generate() %>
                    Pages:
                    <a href="#">[&lt;&lt; Previous]</a>
                    <a href="#">11</a>
                    <b>12</b>
                    <a href="#">13</a>
                    <a href="#">14</a>
                    <a href="#">15</a>
                    <a href="#">16</a>
                    <a href="#">17</a>
                    <a href="#">18</a>
                    <a href="#">19</a>
                    <a href="#">[Next &gt;&gt;]</a>
                  </center>
-->
                <%= tmpl_pg_content_bottom.generate() %>