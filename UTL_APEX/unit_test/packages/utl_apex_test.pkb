create or replace package body utl_apex_test 
as
   C_TEST_ITEM_1 constant utl_apex.ora_name_type := 'P1_STRING_ITEM';
   C_TEST_VALUE_1 constant utl_apex.ora_name_type := '<"Hallo Welt!">';
   C_TEST_ITEM_2 constant utl_apex.ora_name_type := 'P1_DATE_ITEM';
   C_TEST_VALUE_2 constant utl_apex.ora_name_type := '2019-01-01';
   C_INVALID_ITEM constant utl_apex.ora_name_type := 'P1_FOO';
   C_TABLE_NAME constant utl_apex.ora_name_type := 'UTL_APEX_UI_HOME_MAIN';
   C_IG_ID constant utl_apex.ora_name_type := 'test_ig';

  g_application_id number;
  g_item_prefix_convention binary_integer;
  g_item_value_convention boolean;

  procedure initialize
  as
  begin
    select application_id
      into g_application_id
      from apex_applications
     where alias = C_APP_ALIAS;
    
    g_item_prefix_convention := param.get_integer('ITEM_PREFIX_CONVENTION', 'UTL_APEX');
    g_item_value_convention := param.get_boolean('ITEM_VALUE_CONVENTION', 'UTL_APEX');
    
  end initialize;
  
  
  procedure get_session(
    p_page_id in number default c_apex_page)
  as
  begin
    rollback;
    if apex_application.g_instance is null then
      apex_session.create_session(
         p_app_id => g_application_id,
         p_page_id => p_page_id,
         p_username => c_apex_user);
    end if;
    apex_application.g_flow_step_id := p_page_id;
    commit;
  end get_session;
  
  
  procedure drop_session
  as
  begin
    rollback;
    if apex_application.g_instance is not null then
      apex_session.delete_session;
    end if;
    commit;
  end drop_session;
  

  procedure tear_up 
  as
    pragma autonomous_transaction;
  begin
    pit.set_context('DEBUG');
    --get_session;
  end tear_up;
  
  
  procedure delete_apex_session
  as
  begin
    get_session;
    utl_apex.delete_apex_session(apex_application.g_instance);
    ut.expect(apex_application.g_instance).to_be_null;
  end delete_apex_session;
  
  
  procedure create_apex_session
  as
    pragma autonomous_transaction;
  begin
    drop_session;
    utl_apex.create_apex_session(
      p_apex_user => c_apex_user,
      p_application_id => g_application_id,
      p_page_id => c_apex_page);      
    ut.expect(apex_application.g_instance).to_be_greater_than(0);
    drop_session;
  end create_apex_session;
  

  procedure get_true 
  as
  begin
    ut.expect(utl_apex.get_true).to_equal(utl_apex.C_TRUE);
  end get_true;
  

  procedure get_false 
  as
  begin
    ut.expect(utl_apex.get_false).to_equal(utl_apex.C_FALSE);
  end get_false;
  

  procedure get_yes 
  as
  begin
    ut.expect(utl_apex.get_yes).to_equal(utl_apex.C_YES);
  end get_yes;
  

  procedure get_no 
  as
  begin
    ut.expect(utl_apex.get_no).to_equal(utl_apex.C_NO);
  end get_no;
  

  procedure get_bool_true 
  as
  begin
    ut.expect(utl_apex.get_bool(true)).to_equal(utl_apex.C_TRUE);
  end get_bool_true;
  

  procedure get_bool_false 
  as
  begin
    ut.expect(utl_apex.get_bool(false)).to_equal(utl_apex.C_FALSE);
  end get_bool_false;
  

  procedure get_item_value_convention 
  as
  begin
    ut.expect(utl_apex.get_item_value_convention).to_equal(g_item_value_convention);
  end get_item_value_convention;
  

  procedure set_item_value_convention 
  as
  begin
    utl_apex.set_item_value_convention(false);
    ut.expect(utl_apex.get_item_value_convention).to_be_false;
    utl_apex.set_item_value_convention(g_item_value_convention);
  end set_item_value_convention;
  

  procedure set_null_item_value_convention 
  as
  begin
    utl_apex.set_item_value_convention(false);
    utl_apex.set_item_value_convention(NULL);
    ut.expect(utl_apex.get_item_value_convention).to_equal(g_item_value_convention);
  end set_null_item_value_convention;
  

  procedure get_item_prefix_convention 
  as
  begin
    ut.expect(utl_apex.get_item_prefix_convention).to_equal(g_item_prefix_convention);
  end get_item_prefix_convention;
  

  procedure set_item_prefix_convention 
  as
  begin
    utl_apex.set_item_prefix_convention(utl_apex.CONVENTION_APP_ALIAS);
    ut.expect(utl_apex.get_item_prefix_convention).to_equal(utl_apex.CONVENTION_APP_ALIAS);
    utl_apex.set_item_prefix_convention(g_item_prefix_convention);
  end set_item_prefix_convention;
  

  procedure set_invalid_item_prefix_convention 
  as
  begin
    utl_apex.set_item_prefix_convention(27);
  end set_invalid_item_prefix_convention;
  

  procedure set_null_item_prefix_convention 
  as
  begin
    utl_apex.set_item_prefix_convention(utl_apex.CONVENTION_APP_ALIAS);
    utl_apex.set_item_prefix_convention(NULL);
    ut.expect(utl_apex.get_item_prefix_convention).to_equal(g_item_prefix_convention);
  end set_null_item_prefix_convention;
  
  
  procedure get_user
  as
  begin
    get_session;
    ut.expect(utl_apex.get_user).to_equal(C_APEX_USER);
    drop_session;
  end get_user;
  
  
  procedure get_workspace_id
  as
    l_workspace_id number;
  begin
    select workspace_id
      into l_workspace_id
      from apex_applications
     where application_id = g_application_id;
    ut.expect(utl_apex.get_workspace_id(g_application_id)).to_equal(l_workspace_id);
  end get_workspace_id;
  
  
  procedure get_application_id
  as
  begin
    get_session;
    ut.expect(utl_apex.get_application_id).to_equal(g_application_id);
    drop_session;
  end get_application_id;
  
  
  procedure get_application_alias
  as
  begin
    get_session;
    ut.expect(utl_apex.get_application_alias).to_equal(C_APP_ALIAS);
    drop_session;
  end get_application_alias;
  
  
  procedure get_page_id
  as
  begin
    get_session;
    ut.expect(utl_apex.get_page_id).to_equal(C_APEX_PAGE);
    drop_session;
  end get_page_id;
  
  
  procedure get_page_alias
  as
  begin
    get_session;
    ut.expect(utl_apex.get_page_alias).to_equal('HOME');
    drop_session;
  end get_page_alias;
  
  
  procedure get_page_prefix
  as
  begin
    get_session;
    ut.expect(utl_apex.get_page_prefix).to_equal('P1_');
    drop_session;
  end get_page_prefix;
  
  
  procedure get_page_prefix_page
  as
  begin
    get_session;
    utl_apex.set_item_prefix_convention(utl_apex.CONVENTION_PAGE_ALIAS);
    ut.expect(utl_apex.get_page_prefix).to_equal(utl_apex.get_page_alias || '_');
    utl_apex.set_item_prefix_convention(null);
    drop_session;
  end get_page_prefix_page;
  
  
  procedure get_page_prefix_app
  as
  begin
    get_session;
    utl_apex.set_item_prefix_convention(utl_apex.CONVENTION_APP_ALIAS);
    ut.expect(utl_apex.get_page_prefix).to_equal(utl_apex.get_application_alias || '_');
    utl_apex.set_item_prefix_convention(null);
    drop_session;
  end get_page_prefix_app;
  
  
  procedure get_session_id
  as
  begin
    get_session;
    ut.expect(utl_apex.get_session_id).to_be_greater_than(0);
    drop_session;
  end get_session_Id;
  
  
  procedure get_debug
  as
  begin
    ut.expect(utl_apex.get_debug).to_be_false;
  end get_debug;
  
  
  procedure set_debug
  as
    pragma autonomous_transaction;
  begin
    apex_debug.enable;
    ut.expect(utl_apex.get_debug).to_be_true;
    apex_debug.disable;
  end set_debug;
  
  
  procedure get_request_null
  as
  begin
    ut.expect(utl_apex.get_request).to_be_null;
  end get_request_null;
  
  
  procedure get_request
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.get_request).to_equal(l_request);
    apex_application.g_request := null;
  end get_request;
  
  
  procedure get_inserting_true
  as
    l_request utl_apex.ora_name_type := 'CREATE';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.INSERTING).to_be_true;
    apex_application.g_request := null;
  end get_inserting_true;
  
  
  procedure get_inserting_false
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.INSERTING).to_be_false;
    apex_application.g_request := null;
  end get_inserting_false;
  
  
  procedure get_updating_true
  as
    l_request utl_apex.ora_name_type := 'SAVE';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.UPDATING).to_be_true;
    apex_application.g_request := null;
  end get_updating_true;
  
  
  procedure get_updating_false
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.UPDATING).to_be_false;
    apex_application.g_request := null;
  end get_updating_false;
  
  
  procedure get_deleting_true
  as
    l_request utl_apex.ora_name_type := 'DELETE';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.DELETING).to_be_true;
    apex_application.g_request := null;
  end get_deleting_true;
  
  
  procedure get_deleting_false
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.DELETING).to_be_false;
    apex_application.g_request := null;
  end get_deleting_false;
  
  
  procedure request_is_true
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.request_is(l_request)).to_be_true;
    apex_application.g_request := null;
  end request_is_true;
  
  
  procedure request_is_false
  as
    l_request utl_apex.ora_name_type := 'FOO';
  begin
    apex_application.g_request := l_request;
    ut.expect(utl_apex.request_is('SAVE')).to_be_false;
    apex_application.g_request := null;
  end request_is_false;
  
  
  procedure throw_unhandled_request
  as
    l_request utl_apex.ora_name_type := 'MY_REQUEST';
  begin
    apex_application.g_request := l_request;
    utl_apex.unhandled_request;
  exception
    when others then
      apex_application.g_request := null;
      raise;
  end throw_unhandled_request;
  
  
  procedure get_default_date_format
  as
  begin
    ut.expect(utl_apex.get_default_date_format).to_equal(C_DEFAULT_DATE_FORMAT);
  end get_default_date_format;
  
  
  procedure get_default_date_format_explicit
  as
  begin
    ut.expect(utl_apex.get_default_date_format(g_application_id)).to_equal(C_DEFAULT_DATE_FORMAT);
  end get_default_date_format_explicit;
  
  
  procedure get_empty_value
  as
  begin
    get_session;
    ut.expect(utl_apex.get_value(C_TEST_ITEM_1)).to_be_null;
    drop_session;
  end get_empty_value;
  
  
  procedure get_invalid_value_with_error
  as
    l_value utl_apex.ora_name_type;
  begin
    get_session;
    utl_apex.set_item_value_convention(true);
    l_value := utl_apex.get_value('P1_FOO');
    utl_apex.set_item_value_convention(NULL);
    drop_session;
  end get_invalid_value_with_error;
  
  
  procedure get_invalid_value_with_null
  as
    l_value utl_apex.ora_name_type;
  begin
    get_session;
    utl_apex.set_item_value_convention(false);
    ut.expect(utl_apex.get_value('P1_FOO')).to_be_null;
    utl_apex.set_item_value_convention(NULL);
    drop_session;
  end get_invalid_value_with_null;
  
  
  procedure set_value
  as
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    ut.expect(utl_apex.get_value(C_TEST_ITEM_1)).to_equal(C_TEST_VALUE_1);
    utl_apex.set_value(C_TEST_ITEM_1, null);
    drop_session;
  end set_value;
  
  
  procedure set_invalid_value
  as
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_INVALID_ITEM, C_TEST_VALUE_1);
    ut.expect(utl_apex.get_value(C_INVALID_ITEM)).to_equal(C_TEST_VALUE_1);
    utl_apex.set_value(C_INVALID_ITEM, null);
    drop_session;
  end set_invalid_value;
  
  
  procedure user_is_authorized
  as
    l_result utl_apex.flag_type;
  begin
    get_session;
    l_result := utl_apex.user_is_authorized('GRANTED');
    ut.expect(l_result).to_equal(utl_apex.C_TRUE);
    drop_session;
  exception
    when others then
      drop_session;
      raise;
  end user_is_authorized;
  
  
  procedure user_is_not_authorized
  as
    l_result utl_apex.flag_type;
  begin
    get_session;
    l_result := utl_apex.user_is_authorized('NOT_GRANTED');
    ut.expect(l_result).to_equal(utl_apex.C_FALSE);
    drop_session;
  exception
    when others then
      drop_session;
      raise;
  end user_is_not_authorized;
  
  
  procedure invalid_authorization
  as
    l_result utl_apex.flag_type;
  begin
    get_session;
    l_result := utl_apex.user_is_authorized('FOO');
    ut.expect(l_result).to_equal(utl_apex.C_FALSE);
    drop_session;
  exception
    when others then
      drop_session;
      raise;
  end invalid_authorization;
  

  procedure get_page_values 
  as
    C_AMOUNT_ITEMS_ON_PAGE constant binary_integer := 3;
    l_page_values utl_apex.page_value_t;
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    utl_apex.set_value(C_TEST_ITEM_2, C_TEST_VALUE_2);
    l_page_values := utl_apex.get_page_values;
    ut.expect(l_page_values.count).to_equal(C_AMOUNT_ITEMS_ON_PAGE);
    ut.expect(utl_apex.get(l_page_values, C_TEST_ITEM_1)).to_equal(C_TEST_VALUE_1);
    ut.expect(utl_apex.get(l_page_values, C_TEST_ITEM_2)).to_equal(C_TEST_VALUE_2);
    utl_apex.set_value(C_TEST_ITEM_1, NULL);
    utl_apex.set_value(C_TEST_ITEM_2, NULL);
    drop_session;
  end get_page_values;
  

  procedure get_unknown_item_from_page_values 
  as
    C_AMOUNT_ITEMS_ON_PAGE constant binary_integer := 3;
    l_page_values utl_apex.page_value_t;
    l_result utl_apex.ora_name_type;
    pragma autonomous_transaction;
  begin
    get_session;
    l_page_values := utl_apex.get_page_values;
    l_result := utl_apex.get(l_page_values, C_INVALID_ITEM);
    drop_session;
  end get_unknown_item_from_page_values;
  

  procedure get_page_values_from_ig
  as
    C_AMOUNT_ITEMS_ON_PAGE constant binary_integer := 2;
    l_page_values utl_apex.page_value_t;
    pragma autonomous_transaction;
  begin
    get_session(c_ig_page);
    l_page_values := utl_apex.get_page_values(p_static_id => C_IG_ID);
    ut.expect(l_page_values.count).to_equal(C_AMOUNT_ITEMS_ON_PAGE);
    ut.expect(utl_apex.get(l_page_values, 'STRING_ITEM')).to_be_null;
    ut.expect(utl_apex.get(l_page_values, 'DATE_ITEM')).to_be_null;
    drop_session;
  exception
    when others then
      drop_session;
      raise;
  end get_page_values_from_ig;
  
  
  procedure get_value_as_json
  as
    l_page_values utl_apex.page_value_t;
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    l_page_values := utl_apex.get_page_values(p_format => utl_apex.FORMAT_JSON);
    ut.expect(utl_apex.get(l_page_values, C_TEST_ITEM_1)).to_equal(apex_escape.json(C_TEST_VALUE_1));
    utl_apex.set_value(C_TEST_ITEM_1, null);
    drop_session;
  end get_value_as_json;
  
  
  procedure get_value_as_html
  as
    l_page_values utl_apex.page_value_t;
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    l_page_values := utl_apex.get_page_values(p_format => utl_apex.FORMAT_HTML);
    ut.expect(utl_apex.get(l_page_values, C_TEST_ITEM_1)).to_equal(apex_escape.html(C_TEST_VALUE_1));
    utl_apex.set_value(C_TEST_ITEM_1, null);
    drop_session;
  end get_value_as_html;
  

  procedure get_page_record 
  as
    l_item_values UTL_APEX_UI_HOME_MAIN%rowtype;
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    utl_apex.set_value(C_TEST_ITEM_2, C_TEST_VALUE_2);
    execute immediate utl_apex.get_page_record(p_table_name => C_TABLE_NAME) using out l_item_values;
    ut.expect(l_item_values.string_item).to_equal(C_TEST_VALUE_1);
    ut.expect(l_item_values.date_item).to_equal(to_date(C_TEST_VALUE_2, 'YYYY-MM-DD'));
    utl_apex.set_value(C_TEST_ITEM_1, NULL);
    utl_apex.set_value(C_TEST_ITEM_2, NULL);
    drop_session;
  end get_page_record;
  

  procedure get_page_record_from_ig 
  as
    l_item_values UTL_APEX_UI_HOME_MAIN%rowtype;
    pragma autonomous_transaction;
  begin
    get_session(c_ig_page);
    execute immediate 
      utl_apex.get_page_record(
        p_static_id => C_IG_ID,
        p_table_name => C_TABLE_NAME) using out l_item_values;
    ut.expect(l_item_values.string_item).to_be_null;
    ut.expect(l_item_values.date_item).to_be_null;
    drop_session;
  exception
    when others then
      drop_session;
      raise;
  end get_page_record_from_ig;
  

  procedure get_page_script 
  as
    l_script utl_apex.max_char;
    l_record_name utl_apex.ora_name_type := 'l_rec';
    pragma autonomous_transaction;
  begin
    get_session;
    utl_apex.set_value(C_TEST_ITEM_1, C_TEST_VALUE_1);
    utl_apex.set_value(C_TEST_ITEM_2, C_TEST_VALUE_2);
    l_script := utl_apex.get_page_item_script(
                  p_table_name => C_TABLE_NAME,
                  p_application_id => g_application_id,
                  p_page_id => 1,
                  p_record_name => l_record_name);
    ut.expect(l_script).to_match(C_TEST_ITEM_1);
    ut.expect(l_script).to_match(C_TEST_ITEM_2);
    ut.expect(l_script).to_match('begin');
    ut.expect(l_script).to_match('end');
    ut.expect(l_script).to_match(lower(C_TABLE_NAME));
    ut.expect(l_script).to_match(l_record_name);
    utl_apex.set_value(C_TEST_ITEM_1, NULL);
    utl_apex.set_value(C_TEST_ITEM_2, NULL);
    drop_session;
  end get_page_script;
  
  
  procedure validate_simple_sql_name
  as
  begin
    ut.expect(utl_apex.validate_simple_sql_name(C_TABLE_NAME)).to_be_null;
  end validate_simple_sql_name;
  
  
  procedure validate_long_sql_name
  as
    C_MAX_LENGTH constant utl_apex.ora_name_type := '26'; -- Taken from UTL_APEX.VALIDATE_SIMPLE_SQL_NAME
    l_name utl_apex.max_sql_char := 'UTL_APEX_UI_HOME_MAINUTL_APEX_UI_HOME_MAINUTL_APEX_UI_HOME_MAIN';
  begin
    ut.expect(
      utl_apex.validate_simple_sql_name(l_name)
      ).to_equal(to_char(pit.get_message_text(msg.UTL_NAME_TOO_LONG, msg_args(l_name, C_MAX_LENGTH))));
  end validate_long_sql_name;
  
  
  procedure validate_umlaut_sql_name
  as
    l_name utl_apex.max_sql_char := 'ÜTL_ÄPEX_ÜI_HÖME_MÄIN';
  begin
    ut.expect(
      utl_apex.validate_simple_sql_name(l_name)
      ).to_equal(to_char(pit.get_message_text(msg.UTL_NAME_CONTAINS_UMLAUT, msg_args(l_name))));
  end validate_umlaut_sql_name;
  
  
  procedure validate_invalid_sql_name
  as
    l_name utl_apex.max_sql_char := '3TABLE';
  begin
    
    ut.expect(
      utl_apex.validate_simple_sql_name(l_name)
      ).to_equal(to_char(pit.get_message_text(msg.UTL_NAME_INVALID, msg_args(l_name))));
  end validate_invalid_sql_name;
  
  
  procedure tear_down
  as
  begin
    pit.reset_context;
    --drop_session;
  end tear_down;

begin
  initialize;
end utl_apex_test;
/
