
package ru.grw.server.ssvt;

import java.sql.*;

import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Vector;

//import ru.grw.http.core.HttpUser;
import ru.grw.server.http.HttpUser;
import ru.grw.sql.Field;
import ru.grw.util.Function;

public class ViewTable {

    private static Hashtable tables = new Hashtable();

    protected static TableQuery initFields(ServerSSVT ssvt, Hashtable attributes) {
        String tableName = (String) attributes.get("table");
        if (tableName != null) {
            TableQuery tableQuery = (TableQuery) tables.get(tableName);
            if (tableQuery == null) {
                tableQuery = new TableQuery(tableName);
                tables.put(tableName, tableQuery);
                String startName = ssvt.getProperty(tableName + '.' + "startName");
                if (startName == null) startName = "";
                Connection connection = ssvt.getConnection();
                if (connection != null) {
                    String sql = getRecordsSQL(ssvt, tableName);
                    try {
                        PreparedStatement statement = connection.prepareStatement(sql);
                        ResultSet result = statement.executeQuery();
                        ResultSetMetaData meta = result.getMetaData();
                        int columnCount = meta.getColumnCount();
                        for (int index = 1; index <= columnCount; index++) {
                            String name = meta.getColumnName(index);
                            int type = meta.getColumnType(index);
                            int size = meta.getColumnDisplaySize(index);
                            tableQuery.addField(new Field(name, type, size));
                        }
                        result.close();
                        statement.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                    // получить список прав пользователей на таблицу
                    String sqlRights = ssvt.getProperty("getSqlRights");
                    try {
                        PreparedStatement statement = connection.prepareStatement(sqlRights);
                        statement.setString(1, tableName);
                        ResultSet result = statement.executeQuery();
                        while (result.next()) {
                            String userName = result.getString("AD_USER");
                            String table = result.getString("AD_TABLE");
                            String rightSelect = result.getString("AD_SELECT");
                            String rightUpdate = result.getString("AD_UPDATE");
                            String rightInsert = result.getString("AD_INSERT");
                            String rightDelete = result.getString("AD_DELETE");
                            TableUser tableUser = new TableUser(userName, "Y".equals(rightSelect), "Y".equals(rightUpdate), "Y".equals(rightInsert), "Y".equals(rightDelete));
                            tableQuery.addUser(tableUser);
                        }
                        result.close();
                        statement.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                    try {
                        connection.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                    String keyField;
                    int index = 1;
                    while ((keyField = ssvt.getProperty(tableName + ".key." + index)) != null) {
                         tableQuery.addKey(keyField);
                         index++;
                    }
                    String hiddenField;
                    index = 1;
                    while ((hiddenField = ssvt.getProperty(tableName + ".hidden." + index)) != null) {
                         tableQuery.addHidden(hiddenField);
                         index++;
                    }
                }
            }
            return tableQuery;
        }
        return null;
    }

    public static Vector getForm(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        String action = (String) attributes.get("action");
        if (action == null) return getRecords(ssvt, user, attributes);
        return getFormRecord(ssvt, user, attributes);
    }

    public static Vector handlePost(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        String action = (String) attributes.get("action");
        if (action == null) return null;
        if (action.equals("add")) return insertRecord(ssvt, user, attributes);
        else return updateRecord(ssvt, user, attributes);
    }

    protected static String getRecordsSQL(ServerSSVT ssvt, String tableName) {
        String sql = ssvt.getProperty(tableName + '.' + "getRecords");
        if (sql == null) sql = "select * from " + ssvt.getProperty("schema") + '.' + tableName;
        return sql;
    }

    protected static boolean insertLinksToHTML(HttpUser user) {
        boolean insertLinks;
        if (user != null) {
            if (user.isAdministrator() || (true)) {
                insertLinks = true;
            } else {
                insertLinks = true;
            }
        } else {
            insertLinks = true;
        }
        return insertLinks;
    }

    private static Vector insertRecord(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        attributes.put("nocache", "yes");
        TableQuery tableQuery = initFields(ssvt, attributes);
        String tableName = tableQuery.getName();
        String resultMessage;
        boolean execute = false;

        if (user.isAdministrator() || tableQuery.getUser(user.getId()).getInsert()) {
            Connection connection = ssvt.getConnection();
            if (connection != null) {
                // Сформировать SQL запрос
                StringBuffer sql = new StringBuffer("insert into ").append(ssvt.getProperty("schema")).append('.').append(tableName).append(" (");
                StringBuffer values = new StringBuffer("(");
                int index = 0;
                for (Enumeration enumeration = tableQuery.getSequence().elements(); enumeration.hasMoreElements(); ) {
                    Field field = (Field) enumeration.nextElement();
                    String name = field.getName();
                    String value = (String) attributes.get(name); 
                    if (value == null) {
                        try {
                            value = (String) user.getAttribute(name);
                        } catch (Exception e) {
                        }
                    }
                    if (value != null) {
                        if (index > 0) {
                            sql.append(", ");
                            values.append(", ");
                        }
                        sql.append(name);
                        if (value.length() == 0) values.append("NULL");
                        else values.append(getValueField(field, value));
                        index++;
                    }
                }
                sql.append(") values ").append(values).append(")");
                ssvt.log(user.getId() + ": " + sql);
                try {
                    Statement statement = connection.createStatement();
                    statement.execute(sql.toString());
                    statement.close();
                    resultMessage = ssvt.getStringManager().getString("database.insertOk");
                    execute = true;
                } catch (Exception e) {
                    resultMessage = ssvt.getStringManager().getString("database.executeError") + e.toString();
                    ssvt.log(e);
                }
                try {
                    connection.close();
                } catch (Exception e) {
                    ssvt.log(e);
                }
            } else {
                resultMessage = ssvt.getStringManager().getString("database.connectError");
            }
        } else {
            resultMessage = ssvt.getStringManager().getString("database.notRights");
        }

        String title = ssvt.getStringManager().getString(tableName + '.' + "addRecordTitle");
        return getHtmlResultPage(ssvt, tableQuery, user, attributes, title, resultMessage, execute);
    }


    private static Vector updateRecord(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        attributes.put("nocache", "yes");
        TableQuery tableQuery = initFields(ssvt, attributes);
        String tableName = tableQuery.getName();
        // Получить вектор ключевых полей
        Vector keys = tableQuery.getKeys();
        boolean execute = false;
        String resultMessage = "";
        if (attributes.get("delRecord") == null) {
            // Выполнить UPDATE записи
            if (user.isAdministrator() || tableQuery.getUser(user.getId()).getUpdate()) {
                Connection connection = ssvt.getConnection();
                if (connection != null) {
                    // Сформировать SQL запрос
                    StringBuffer sql = new StringBuffer("update ").append(ssvt.getProperty("schema")).append('.').append(tableName).append(" set ");
                    // Установить значения изменяемых полей
                    int index = 0;
                    for (Enumeration e = tableQuery.getSequence().elements(); e.hasMoreElements(); ) {
                        Field field = (Field) e.nextElement();
                        String name = field.getName();
                        if (!keys.contains(field)) {
                            String value = (String) attributes.get(field.getName());
                            if (value != null) {
                                if (index > 0) sql.append(", ");
                                sql.append(name).append('=');
                                if (value.length() == 0) sql.append("NULL");
                                else sql.append(getValueField(field, value));
                                index++;
                            } else {
//
                                String keyField = tableName + '.' + "FORM" + '.' + name;
                                String objectName = ssvt.getProperty(keyField, "INPUT");
                                String type = ssvt.getProperty(keyField + '.' + "TYPE", "TEXT");
                                if ("CHECKBOX".equals(type) && objectName.equals("INPUT")) {
                                    if (index > 0) sql.append(", ");
                                    sql.append(name).append('=');
                                    String defaultValue = ssvt.getProperty(tableName + '.' + "FORM" + '.' + "CHECKBOX" + '.' + "DEFAULT", "NO");
                                    if ("NULL".equals(defaultValue)) sql.append("null");
                                    else sql.append(getValueField(field, defaultValue));
                                    index++;
                                } 
//
                            }
                        }
                    }
                    // Установить значения уникальных полей
                    sql.append(" where ");
                    addKeyFieldsToSQL(keys, sql, attributes);
                    // Выполнить сформированный запрос
                    ssvt.log(user.getId() + ": " + sql);
                    int updateRecords = 0;
                    if (index > 0) {
                        try {
                            Statement statement = connection.createStatement();
                            updateRecords = statement.executeUpdate(sql.toString());
                            statement.close();
                            switch (updateRecords) {
                                case 0: resultMessage = "Запись не изменена.";
                                        break;
                                case 1: resultMessage = "Операция редактирования записи выполнена успешно.";
                                        execute = true;
                                        break;
                                default: resultMessage = "Изменено " + updateRecords + " записей.";
                            }
                        } catch (Exception e) {
                            resultMessage = ssvt.getStringManager().getString("database.executeError") + e.toString();
                            ssvt.log(e);
                        }
                    }
                    try {
                        connection.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                } else {
                    resultMessage = ssvt.getStringManager().getString("database.connectError");
                }
            } else {
                resultMessage = ssvt.getStringManager().getString("database.notRights");
            }
        } else {
            // Удалить запись
            if (user.isAdministrator() || tableQuery.getUser(user.getId()).getDelete()) {
                Connection connection = ssvt.getConnection();
                if (connection != null) {
                    // Сформировать SQL запрос
                    StringBuffer sql = new StringBuffer("delete from ").append(ssvt.getProperty("schema")).append('.').append(tableName).append(" where ");
                    addKeyFieldsToSQL(keys, sql, attributes);
                    // Выполнить сформированный запрос
                    ssvt.log(user.getId() + ": " + sql);
                    int deleteRecords = 0;
                    try {
                        Statement statement = connection.createStatement();
                        deleteRecords = statement.executeUpdate(sql.toString());
                        statement.close();
                        switch (deleteRecords) {
                            case 0: resultMessage = "Запись не удалена";
                                    break;
                            case 1: resultMessage = "Операция удаления записи выполнена успешно.";
                                    execute = true;
                                    break;
                            default: resultMessage = "Удалено " + deleteRecords + " записей.";
                        }
                    } catch (Exception e) {
                        resultMessage = ssvt.getStringManager().getString("database.executeError") + e.toString();
                        ssvt.log(e);
                    }
                    try {
                        connection.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                } else {
                    resultMessage = ssvt.getStringManager().getString("database.connectError");
                }
            } else {
                resultMessage = ssvt.getStringManager().getString("database.notRights");
            }
        }

        String title;
        if (attributes.get("delRecord") == null) {
            title = ssvt.getStringManager().getString(tableName + '.' + "editRecordTitle");
        } else {
            title = ssvt.getStringManager().getString(tableName + '.' + "deleteRecordTitle");
        }
        return getHtmlResultPage(ssvt, tableQuery, user, attributes, title, resultMessage, execute);
    }

    public static Vector getFormRecord(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        attributes.put("nocache", "yes");
        Vector form = new Vector();
        Hashtable values = new Hashtable();
        TableQuery tableQuery = initFields(ssvt, attributes);
        String tableName = tableQuery.getName();
        String startName = ssvt.getProperty(tableName + '.' + "startName", "");
        // Получить вектор ключевых полей
        Vector keys = tableQuery.getKeys();
        form.addElement("<html><head><title>");
        String action = (String) attributes.get("action");
        String title;
        boolean add = "add".equals(action);
        if (add) {
            title = ssvt.getStringManager().getString(tableName + '.' + "addRecordTitle");
        } else {
            title = ssvt.getStringManager().getString(tableName + '.' + "editRecordTitle");
        }
        form.addElement(title);
        form.addElement("</title></head><body>");
        form.addElement("<center><h1>" + title + "</h1></center>");

        String uri = (String) attributes.get("uri");
        String actionForm = ssvt.getProperty(tableName + '.' + "actionForm", uri);
        form.addElement("<form method=\"POST\" action=\"" + actionForm +"\">");

        if (!add) {
            // Получить запись по уникальному ключу
            Connection connection = ssvt.getConnection();
            if (connection != null) {
                // Сформировать SQL запрос
//                StringBuffer sql = new StringBuffer(ssvt.getProperty(tableName + '.' + "getRecords"));
                StringBuffer sql = new StringBuffer(getRecordsSQL(ssvt, tableName));
                if (keys.size() > 0) {
                    sql.append(" where ");
                    addKeyFieldsToSQL(keys, sql, attributes);
                    // Выполнить сформированный запрос и занести значения полей в [values]
                    ssvt.log(user.getId() + ": " + sql);
                    try {
                        PreparedStatement statement = connection.prepareStatement(sql.toString());
                        ResultSet record = statement.executeQuery();
                        if (record.next()) {
                            for (Enumeration e = tableQuery.getSequence().elements(); e.hasMoreElements(); ) {
                                Field field = (Field) e.nextElement();
                                String value = record.getString(field.getName());
                                if (value != null) 
                                    values.put(field.getName(), value);
                            }
                        }
                        record.close();
                        statement.close();
                    } catch (Exception e) {
                        ssvt.log(e);
                    }
                }
                try {
                    connection.close();
                } catch (Exception e) {
                    ssvt.log(e);
                }
            }
        }

        if (!add && (values.size() == 0)) {
            form.addElement("Запись для редактирования не найдена.");
        } else {
            // Вставить в форму невидимые поля 
            form.addElement("<INPUT TYPE=\"HIDDEN\" NAME=\"table\" VALUE=\"" + tableName + "\">");
            form.addElement("<INPUT TYPE=\"HIDDEN\" NAME=\"action\" VALUE=\"" + action + "\">");

            StringBuffer buf;
            if (!add) {
                // Вставить в форму невидимые поля уникального ключа при редактировании записи
                for (Enumeration e = keys.elements(); e.hasMoreElements(); ) {
                    Field field = (Field) e.nextElement();
                    String name = field.getName();
                    buf = new StringBuffer("<INPUT TYPE=\"HIDDEN\" NAME=\"").append(name).append("\" VALUE=\"").append(values.get(name)).append("\">");
                    form.addElement(buf.toString());
                }
            }

            String checkValue = ssvt.getProperty(tableName + '.' +"FORM" + '.' + "CHECKBOX" + '.' + "VALUE", "YES");
            // Вставить в форму редактируемые поля записи
            form.addElement("<table>");
            for (Enumeration e = tableQuery.getSequence().elements(); e.hasMoreElements(); ) {
                Field field = (Field) e.nextElement();
                String name = field.getName();
                if (!tableQuery.isHiddenField(name) && (user.getAttribute(name.substring(startName.length())) == null)) {
                    String keyField = tableName + '.' + "FORM" + '.' + name;
                    String addField = null;
                    buf = new StringBuffer("<tr><td>");
                    buf.append(ssvt.getStringManager().getString(tableName + '.' + name)).append("</td><td>").append("&nbsp;").append("</td><td>");
                    String valueField = (String) values.get(name);
                    if (keys.contains(field) && !add) {
                        // При редактировании  поле уникального ключа недоступно для редактирования
                        if (valueField != null) {
                            buf.append("<B>").append(valueField).append("</B>");
                        }
                    } else {
                        String objectName = ssvt.getProperty(keyField, "INPUT");
                        if (objectName.equals("INPUT")) {
                            buf.append("<INPUT TYPE=\"");
                            String type = ssvt.getProperty(keyField + '.' + "TYPE", "TEXT");
                            buf.append(type).append("\" NAME=\"").append(name).append("\" VALUE=\"");
                            if ("TEXT".equals(type)) {
                                if (valueField != null) {
                                    buf.append(valueField);
                                }
                                buf.append("\" MAXLENGTH=\"");
                                if (field.getSize() > 64) buf.append(64);
                                else buf.append(field.getSize());
                                buf.append("\" SIZE=\"").append(field.getSize()).append('\"');
                            } else {
                                if ("CHECKBOX".equals(type)) {
                                    buf.append(checkValue).append("\"");
                                    if ((valueField != null) && valueField.equals(checkValue)) {
                                        buf.append(" CHECKED");
                                    }
                                } 
                            }
                            buf.append('>');
                        } else {
                            if (objectName.equals("SELECT")) {
                                addField = ssvt.getProperty(keyField + '.' + "ADD");
                                buf.append("<SELECT ");
                                buf.append("NAME=\"").append(name).append("\"");
                                buf.append(">");
                                Connection connection = ssvt.getConnection();
                                if (connection != null) {
                                    try {
                                        String sql = ssvt.getProperty(keyField + '.' + "OPTIONS");
                                        Statement statement = connection.createStatement();
                                        ResultSet result = statement.executeQuery(sql);
                                        while (result.next()) {
                                            buf.append("<OPTION>").append(result.getString(1));
                                        }
                                        result.close();
                                        statement.close();
                                    } catch (Exception sql) {
                                        ssvt.log(sql);
                                    }
                                    try {
                                        connection.close();
                                    } catch (Exception sql) {
                                        ssvt.log(sql);
                                    }
                                }
                                buf.append("</SELECT>");
                            }
                        }
                    }
                    buf.append("<td>");
                    if (addField != null) {
                        buf.append("<INPUT TYPE=SUBMIT NAME=\"" + addField + "\" VALUE=\"Изменить\">");
                        buf.append("<INPUT TYPE=SUBMIT NAME=\"" + keyField + '.' + "ADD" + "\" VALUE=\"Изменить\">");
                    } 
                    buf.append("</td>");
                    buf.append("</td></tr>");
                    form.addElement(buf.toString());
                }
            }

            if (!add) form.addElement("<tr><td>" + ssvt.getStringManager().getString(tableName + '.' + "deleteRecord") + "</td><td>" + "&nbsp;" + "</td><td>" + "<INPUT TYPE=\"CHECKBOX\" NAME=\"delRecord\" VALUE=\"" + checkValue + "\"></td></tr>");
            form.addElement("</table><p>");
            form.addElement("<INPUT TYPE=SUBMIT NAME=\"ENTER\" VALUE=\"Ввод\">&nbsp;&nbsp;&nbsp;<INPUT TYPE=RESET VALUE=\"Очистить\"></form>");
        }
        form.addElement("</body></html>");
        return form;
    }

    public static Vector getRecords(ServerSSVT ssvt, HttpUser user, Hashtable attributes) {
        TableQuery tableQuery = initFields(ssvt, attributes);
        String tableName = tableQuery.getName();
        Vector sequence = tableQuery.getSequence();

        String uri = (String) attributes.get("uri");
        String uriTable = uri + "?table=" + tableName;
        String addRecord = ssvt.getProperty(tableName + '.' + "addRecord", uriTable);
        String editRecord = ssvt.getProperty(tableName + '.' + "editRecord", uriTable);
        String startName = ssvt.getProperty(tableName + '.' + "startName", "");
        String maxRecords = ssvt.getProperty(tableName + '.' + "maxRecords", "100");
        int max;
        try {
            max = Integer.parseInt(maxRecords);
            if (max < 50) max = 50;
        } catch (Exception e) {
            max = 100;
        }

        String strPage = (String) attributes.get("page");
        int page;
        try {
            page = Integer.parseInt(strPage);
        } catch (Exception e) {
            page = 1;
        }


        boolean insertLinks = insertLinksToHTML(user);

        Vector form = new Vector();
        form.addElement("<html><head><title>");
        String title = ssvt.getStringManager().getString(tableName + '.' + "title");
        form.addElement(title);
        form.addElement("</title></head><body>");

//        String script = ssvt.getProperty("script");
//        if (script != null) 
//            form.addElement(script);

        form.addElement("<center><h1>" + title + "</h1></center>");

        form.addElement(ssvt.getStringManager().getString(tableName + '.' + "comment"));

        form.addElement("<center>");
        form.addElement("<table border width=" + ssvt.getProperty(tableName + '.' + "width", "%95") + '>');
        // Вывести заголовок таблицы
        StringBuffer header = new StringBuffer("<tr>");
        for (Enumeration e = sequence.elements(); e.hasMoreElements(); ) {
            Field field = (Field) e.nextElement();
            String name = field.getName();
            if (!tableQuery.isHiddenField(name) && (user.getAttribute(name.substring(startName.length())) == null)) {
                header.append("<th>" + ssvt.getStringManager().getString(tableName + '.' + name) + "</th>");
            }
        }
        form.addElement(header.append("</tr>").toString());

        int count = 0; // Количество выбранных записей
        // Вывести тело таблицы
        Connection connection = ssvt.getConnection();
        if (connection != null) {
            // Сформировать SQL запрос
            StringBuffer sql = new StringBuffer(getRecordsSQL(ssvt, tableName));
            int index = 0;
            boolean whereIs = false;
            for (Enumeration e = user.getKeyAttributes(); e.hasMoreElements(); ) {
                String userNameAttribute = (String) e.nextElement();
                Field field = (Field) tableQuery.getField(startName + userNameAttribute);
                if (field != null) {
                    Object value = user.getAttribute(userNameAttribute);
                    index++;
                    if (index == 1) {
                        sql.append(" where ");
                        whereIs = true;
                    } else {
                        sql.append(" and ");
                    }
                    sql.append(' ').append(startName).append(userNameAttribute).append('=').append(getValueField(field, value));
                }
            }
            // Добавить в SQL запрос условия выброки записей установленные пользователем

            // Добавить в SQL запрос предикаты сортировки записей

//            sql.append(" ");

            // Выполнить запрос
            try {

                PreparedStatement statement = connection.prepareStatement(sql.toString());
                ResultSet result = statement.executeQuery();
                int beginNumber = (page - 1) * max;
                int endNumber = page * max;
                while (result.next()) {
                    if ((count >= beginNumber) && (count < endNumber)) {
                        Enumeration e;
                        // Получить значения полей записи
                        Hashtable values = new Hashtable();
                        for (e = sequence.elements(); e.hasMoreElements(); ) {
                            Field field = (Field) e.nextElement();
                            String valueField = result.getString(field.getName());
                            if (valueField != null) values.put(field.getName(), valueField);
                        }
                        // Вывести запись
                        StringBuffer buf = new StringBuffer("<tr>");
                        for (e = sequence.elements(), index = 0; e.hasMoreElements();) {
                            Field field = (Field) e.nextElement();
                            String name = field.getName();
                            if (!tableQuery.isHiddenField(name) && (user.getAttribute(name.substring(startName.length())) == null)) {
                                index++;
                                String valueField = (String)values.get(name);
                                buf.append("<td>");
                                if ((index == 1) && insertLinks) {
                                    buf.append("<A HREF=\"");
                                    StringBuffer link = new StringBuffer(editRecord).append("&action=edit");
                                    for (Enumeration keys = tableQuery.getKeys().elements(); keys.hasMoreElements(); ) {
                                        Field key = (Field) keys.nextElement();
                                        String valueKey = (String) values.get(key.getName());
                                        if (valueKey != null) {
                                            link.append('&').append(key.getName()).append('=');
                                            for (int pos = 0; pos < valueKey.length(); pos++) {
                                                char c = valueKey.charAt(pos);
// если русские буквы ?
                                                if (c == ' ') link.append("%20");
                                                else link.append(c);
                                            }
                                        }
                                    }
                                    buf.append(link).append('\"');
//                                    if (script != null) buf.append(' ').append("onClick=\"return doClick(\'").append(link).append("\')\"");
                                    buf.append('>');
                                }
                                if (valueField == null)
                                    buf.append("&nbsp;");
                                else
                                    buf.append(valueField);
                                if ((index == 1) && insertLinks) {
                                    buf.append("</A>");
                                }
                                buf.append("</td>");
                            }
                        }
                        buf.append("</tr>");
                        form.addElement(buf.toString());
                    }
                    count++;
                }
                result.close();
                statement.close();
            } catch (Exception e) {
                ssvt.log(e);
            }
            try {
                connection.close();
            } catch (Exception e) {
                ssvt.log(e);
            }
        }
        form.addElement("</table><p>");
        form.addElement("</center>");
        form.addElement("Всего записей: " + count + "<p>");
        if (count > max) {
            int countPage = count / max;
            if (count % max > 0) countPage++;
            StringBuffer buf = new StringBuffer("Страницы: ");
            for (int index = 1; index <= countPage; index++) {
                if (index != page) {
                    buf.append("<a href=\"" + uriTable + "&page=" + index + "\">"); 
                } else {
                    buf.append("<b>");
                }
                buf.append(index);
                if (index != page) {
                    buf.append("</a>");
                } else {
                    buf.append("</b>");
                }
                if (index < countPage) {
                    buf.append(", ");
                }
            }
            buf.append("<p>");
            form.addElement(buf.toString());
        }
        if (insertLinks) 
            form.addElement("<a href=\"" + addRecord + "&action=add\">" + ssvt.getStringManager().getString(tableName + '.' + "addRecord") + "</a><p>");
        form.addElement("</body></html>");
        return form;
    }

    public static Vector getNoAccessPage(ServerSSVT ssvt) {
        Vector form = new Vector();
        form.addElement("<html><head><title>");
        String title = ssvt.getStringManager().getString("titleNoAccessPage");
        form.addElement(title);
        form.addElement(ssvt.getStringManager().getString("messageNoAccessPage"));
        form.addElement("</body></html>");
        return form;
    }

    private static void addKeyFieldsToSQL(Vector keys, StringBuffer sql, Hashtable attributes) {
        int index = 0;
        for (Enumeration e = keys.elements(); e.hasMoreElements(); index++) {
        Field field = (Field) e.nextElement();
        if (index > 0) sql.append(" and ");
            sql.append(field.getName()).append('=');
            sql.append(getValueField(field, attributes));
        }
    }

    private static String getValueField(Field field, Hashtable attributes) {
        return getValueField(field, attributes.get(field.getName()));
    }

    private static String getValueField(Field field, Object object) {
        switch (field.getType()) {
            case 1:
            case 12: return '\'' + object.toString() + '\'';
        }
        return object.toString();
    }

    private static Vector getHtmlResultPage(ServerSSVT ssvt, TableQuery table, HttpUser user, Hashtable attributes, String title, String resultMessage, boolean execute) {
        Vector form = new Vector();
        form.addElement("<html><head><title>");
        form.addElement(title);
        form.addElement("</title></head><body>");
        form.addElement("<center><h1>" + title + "</h1></center>");
        form.addElement(resultMessage);
        form.addElement("<hr>");
        if (execute) {
            String tableName = table.getName();
            form.addElement(ssvt.getStringManager().getString("admin.reloadMessage"));
            form.addElement("<hr>");
            String uri = (String) attributes.get("uri");
            String uriTable = uri + "?table=" + tableName;
            String addRecord = ssvt.getProperty(tableName + '.' + "addRecord", uriTable);
            String viewRecords = ssvt.getProperty(tableName + '.' + "title", uriTable);
//            String page = (String) attributes.get("page");
//            if (page != null) viewRecords = viewRecords + "&page=" + page;
            form.addElement("<a href=\"" + addRecord + "&action=add\">" + ssvt.getStringManager().getString(tableName + '.' + "addRecord") + "</a><br>");
            form.addElement("<a href=\"" + viewRecords + "\">" + ssvt.getStringManager().getString(tableName + '.' + "title") + "</a><p>");
        } else {
            form.addElement("User ID: " + user.getId() + "<p>");
            form.addElement("Time : " + Function.getTimeLabel() + "<p>");
            form.addElement(ssvt.getStringManager().getString("admin.sendMessage"));
        }
        form.addElement("</body></html>");
        return form;
    }

}