```sql

create table public.alembic_version (
                                        tableoid oid not null,
                                        cmax cid not null,
                                        xmax xid not null,
                                        cmin cid not null,
                                        xmin xid not null,
                                        ctid tid not null,
                                        version_num character varying(32) primary key not null
);

create table public.chat_messages (
                                      tableoid oid not null,
                                      cmax cid not null,
                                      xmax xid not null,
                                      cmin cid not null,
                                      xmin xid not null,
                                      ctid tid not null,
                                      session_id character varying(36) not null,
                                      message_id integer not null,
                                      role messagerole not null,
                                      content text not null,
                                      reasoning_content json,
                                      parent_message_id integer,
                                      status messagestatus not null,
                                      is_favorited boolean not null,
                                      response_time_ms integer,
                                      error_info json,
                                      "references" json,
                                      token_usage json,
                                      created_at timestamp with time zone not null default now(),
                                      updated_at timestamp with time zone not null default now(),
                                      file_ids json,
                                      actions json,
                                      primary key (session_id, message_id),
                                      foreign key (session_id) references public.chat_sessions (id)
                                          match simple on update no action on delete no action
);
create index ix_chat_messages_is_favorited on chat_messages using btree (is_favorited);
create index idx_chat_messages_session_parent on chat_messages using btree (session_id, parent_message_id);
create index idx_chat_messages_session_created on chat_messages using btree (session_id, created_at);
create index idx_chat_messages_status on chat_messages using btree (status);
create index idx_chat_messages_created_at on chat_messages using btree (created_at);
create index idx_chat_messages_parent_message_id on chat_messages using btree (parent_message_id);
create index idx_chat_messages_is_favorited on chat_messages using btree (is_favorited);

create table public.chat_sessions (
                                      tableoid oid not null,
                                      cmax cid not null,
                                      xmax xid not null,
                                      cmin cid not null,
                                      xmin xid not null,
                                      ctid tid not null,
                                      id character varying(36) primary key not null,
                                      user_id character varying(255),
                                      title character varying(200),
                                      current_message_id integer,
                                      status sessionstatus not null,
                                      is_deleted boolean not null,
                                      created_at timestamp with time zone not null default now(),
                                      updated_at timestamp with time zone not null default now(),
                                      last_activity_at timestamp with time zone
);
create index ix_chat_sessions_user_id on chat_sessions using btree (user_id);
create index ix_chat_sessions_current_message_id on chat_sessions using btree (current_message_id);

create table public.invite_codes (
                                     tableoid oid not null,
                                     cmax cid not null,
                                     xmax xid not null,
                                     cmin cid not null,
                                     xmin xid not null,
                                     ctid tid not null,
                                     id integer primary key not null default nextval('invite_codes_id_seq'::regclass),
                                     code character varying(32) not null, -- 邀请码（唯一）
                                     inviter_user_id character varying(36) not null, -- 邀请人用户ID
                                     is_used boolean not null, -- 是否已被使用
                                     used_by_user_id character varying(36), -- 使用者用户ID
                                     used_at timestamp with time zone, -- 使用时间
                                     created_at timestamp with time zone not null,
                                     foreign key (inviter_user_id) references public.users (id)
                                         match simple on update no action on delete no action
);
create unique index idx_invite_code_code on invite_codes using btree (code);
create index idx_invite_code_inviter on invite_codes using btree (inviter_user_id);
create index idx_invite_code_inviter_used on invite_codes using btree (inviter_user_id, is_used);
create unique index ix_invite_codes_code on invite_codes using btree (code);
create index ix_invite_codes_inviter_user_id on invite_codes using btree (inviter_user_id);
create index ix_invite_codes_is_used on invite_codes using btree (is_used);
comment on column public.invite_codes.code is '邀请码（唯一）';
comment on column public.invite_codes.inviter_user_id is '邀请人用户ID';
comment on column public.invite_codes.is_used is '是否已被使用';
comment on column public.invite_codes.used_by_user_id is '使用者用户ID';
comment on column public.invite_codes.used_at is '使用时间';

create table public.message_favorite_collections (
                                                     tableoid oid not null,
                                                     cmax cid not null,
                                                     xmax xid not null,
                                                     cmin cid not null,
                                                     xmin xid not null,
                                                     ctid tid not null,
                                                     id character varying(36) primary key not null,
                                                     user_id character varying(255) not null,
                                                     session_id character varying(36) not null,
                                                     message_ids json not null,
                                                     created_at timestamp with time zone not null default now(),
                                                     updated_at timestamp with time zone not null default now(),
                                                     foreign key (session_id) references public.chat_sessions (id)
                                                         match simple on update no action on delete no action
);
create index idx_favorite_collections_user_id on message_favorite_collections using btree (user_id);
create index idx_favorite_collections_session_id on message_favorite_collections using btree (session_id);
create index idx_favorite_collections_created_at on message_favorite_collections using btree (created_at);
create index ix_message_favorite_collections_session_id on message_favorite_collections using btree (session_id);
create index ix_message_favorite_collections_user_id on message_favorite_collections using btree (user_id);

create table public.message_shares (
                                       tableoid oid not null,
                                       cmax cid not null,
                                       xmax xid not null,
                                       cmin cid not null,
                                       xmin xid not null,
                                       ctid tid not null,
                                       id character varying(36) primary key not null,
                                       user_id character varying(255) not null,
                                       session_id character varying(36) not null,
                                       message_ids json not null,
                                       is_active boolean not null,
                                       view_count integer not null,
                                       created_at timestamp with time zone not null default now(),
                                       updated_at timestamp with time zone not null default now(),
                                       foreign key (session_id) references public.chat_sessions (id)
                                           match simple on update no action on delete no action
);
create index idx_message_shares_user_id on message_shares using btree (user_id);
create index idx_message_shares_session_id on message_shares using btree (session_id);
create index idx_message_shares_is_active on message_shares using btree (is_active);
create index idx_message_shares_created_at on message_shares using btree (created_at);
create index ix_message_shares_is_active on message_shares using btree (is_active);
create index ix_message_shares_session_id on message_shares using btree (session_id);
create index ix_message_shares_user_id on message_shares using btree (user_id);

create table public.precedent_documents (
                                            tableoid oid not null,
                                            cmax cid not null,
                                            xmax xid not null,
                                            cmin cid not null,
                                            xmin xid not null,
                                            ctid tid not null,
                                            id integer primary key not null default nextval('precedent_documents_id_seq'::regclass),
                                            document_id character varying(300) not null, -- 文档唯一标识，与 RAG 系统中的 document_id 一致
                                            matter character varying(300) not null, -- 判例名称，如 Matter of Dhanasar
                                            note character varying(500), -- 判例备注，如 , 26 I&N Dec. 884 (AAO 2016)
                                            decision_date character varying(100), -- 决定日期字符串
                                            result character varying(50), -- 决定结果：sustained, dismissed, withdrawn, unknown
                                            form_type json, -- 相关表格类型列表，如 ["Form I-140", "Form I-485"]
                                            case_type json, -- 案例类型列表
                                            legal_provisions json, -- 法律条款列表
                                            cited_precedents json, -- 引用的判例列表
                                            cited_court_cases json, -- 引用的法院案例列表
                                            superseded_info text, -- 被取代信息
                                            policy_memorandum_summary text, -- 政策备忘录摘要
                                            full_summary text, -- 完整案例摘要
                                            abstract text, -- 案例摘要/简介
                                            full_text text, -- 判例原文（从 PDF 解析或直接获取）
                                            full_text_length integer not null, -- 原文字符长度
                                            pdf_urls json, -- PDF 下载链接列表
                                            source character varying(50) not null, -- 数据来源：uscis, eoir
                                            created_at timestamp with time zone not null,
                                            updated_at timestamp with time zone not null
);
create unique index idx_precedent_document_id on precedent_documents using btree (document_id);
create index idx_precedent_matter on precedent_documents using btree (matter);
create index idx_precedent_source on precedent_documents using btree (source);
create unique index ix_precedent_documents_document_id on precedent_documents using btree (document_id);
create index ix_precedent_documents_matter on precedent_documents using btree (matter);
comment on column public.precedent_documents.document_id is '文档唯一标识，与 RAG 系统中的 document_id 一致';
comment on column public.precedent_documents.matter is '判例名称，如 Matter of Dhanasar';
comment on column public.precedent_documents.note is '判例备注，如 , 26 I&N Dec. 884 (AAO 2016)';
comment on column public.precedent_documents.decision_date is '决定日期字符串';
comment on column public.precedent_documents.result is '决定结果：sustained, dismissed, withdrawn, unknown';
comment on column public.precedent_documents.form_type is '相关表格类型列表，如 ["Form I-140", "Form I-485"]';
comment on column public.precedent_documents.case_type is '案例类型列表';
comment on column public.precedent_documents.legal_provisions is '法律条款列表';
comment on column public.precedent_documents.cited_precedents is '引用的判例列表';
comment on column public.precedent_documents.cited_court_cases is '引用的法院案例列表';
comment on column public.precedent_documents.superseded_info is '被取代信息';
comment on column public.precedent_documents.policy_memorandum_summary is '政策备忘录摘要';
comment on column public.precedent_documents.full_summary is '完整案例摘要';
comment on column public.precedent_documents.abstract is '案例摘要/简介';
comment on column public.precedent_documents.full_text is '判例原文（从 PDF 解析或直接获取）';
comment on column public.precedent_documents.full_text_length is '原文字符长度';
comment on column public.precedent_documents.pdf_urls is 'PDF 下载链接列表';
comment on column public.precedent_documents.source is '数据来源：uscis, eoir';

create table public.subscribe_message_templates (
                                                    tableoid oid not null,
                                                    cmax cid not null,
                                                    xmax xid not null,
                                                    cmin cid not null,
                                                    xmin xid not null,
                                                    ctid tid not null,
                                                    template_type character varying(32) primary key not null, -- 模板类型: activation(激活通知), reminder(次日提醒)
                                                    template_id character varying(128) not null, -- 微信订阅消息模板 ID
                                                    page_path character varying(256) not null, -- 点击通知跳转的小程序页面
                                                    fields_config text not null, -- 模板字段配置（JSON），支持 {nickname}, {current_time} 变量
                                                    description character varying(500), -- 模板说明
                                                    created_at timestamp with time zone not null default now(),
                                                    updated_at timestamp with time zone not null default now()
);
comment on column public.subscribe_message_templates.template_type is '模板类型: activation(激活通知), reminder(次日提醒)';
comment on column public.subscribe_message_templates.template_id is '微信订阅消息模板 ID';
comment on column public.subscribe_message_templates.page_path is '点击通知跳转的小程序页面';
comment on column public.subscribe_message_templates.fields_config is '模板字段配置（JSON），支持 {nickname}, {current_time} 变量';
comment on column public.subscribe_message_templates.description is '模板说明';

create table public.uploaded_files (
                                       tableoid oid not null,
                                       cmax cid not null,
                                       xmax xid not null,
                                       cmin cid not null,
                                       xmin xid not null,
                                       ctid tid not null,
                                       id character varying(50) primary key not null,
                                       user_id character varying(255) not null,
                                       session_id character varying(36),
                                       file_name character varying(500) not null,
                                       file_size integer not null,
                                       mime_type character varying(100),
                                       file_type character varying(50),
                                       storage_path character varying(500),
                                       status filestatus not null,
                                       parsed_content_path character varying(500),
                                       content_length integer not null,
                                       token_usage integer not null,
                                       error_code character varying(50),
                                       error_message text,
                                       expires_at timestamp with time zone,
                                       created_at timestamp with time zone not null,
                                       updated_at timestamp with time zone not null
);
create index idx_uploaded_files_created_at on uploaded_files using btree (created_at);
create index idx_uploaded_files_expires_at on uploaded_files using btree (expires_at);
create index idx_uploaded_files_session_id on uploaded_files using btree (session_id);
create index idx_uploaded_files_status on uploaded_files using btree (status);
create index idx_uploaded_files_user_id on uploaded_files using btree (user_id);
create index ix_uploaded_files_expires_at on uploaded_files using btree (expires_at);
create index ix_uploaded_files_session_id on uploaded_files using btree (session_id);
create index ix_uploaded_files_status on uploaded_files using btree (status);
create index ix_uploaded_files_user_id on uploaded_files using btree (user_id);

create table public.uscis_data_categories (
                                              tableoid oid not null,
                                              cmax cid not null,
                                              xmax xid not null,
                                              cmin cid not null,
                                              xmin xid not null,
                                              ctid tid not null,
                                              id integer primary key not null default nextval('uscis_data_categories_id_seq'::regclass),
                                              category_key character varying(100) not null, -- 类别唯一标识符，如 form_processing, i485
                                              name_zh character varying(200) not null, -- 中文名称
                                              name_en character varying(200), -- 英文名称
                                              parent_id integer, -- 父类别ID，主类别为空
                                              summary text, -- 类别摘要（约100字，LLM生成）
                                              representative_infos json, -- 代表性数据项的 info 字段列表
                                              item_count integer not null, -- 该类别下的数据项数量
                                              created_at timestamp with time zone not null,
                                              updated_at timestamp with time zone not null,
                                              foreign key (parent_id) references public.uscis_data_categories (id)
                                                  match simple on update no action on delete no action
);
create index idx_data_categories_category_key on uscis_data_categories using btree (category_key);
create index idx_data_categories_parent_id on uscis_data_categories using btree (parent_id);
create unique index ix_uscis_data_categories_category_key on uscis_data_categories using btree (category_key);
create index ix_uscis_data_categories_parent_id on uscis_data_categories using btree (parent_id);
comment on column public.uscis_data_categories.category_key is '类别唯一标识符，如 form_processing, i485';
comment on column public.uscis_data_categories.name_zh is '中文名称';
comment on column public.uscis_data_categories.name_en is '英文名称';
comment on column public.uscis_data_categories.parent_id is '父类别ID，主类别为空';
comment on column public.uscis_data_categories.summary is '类别摘要（约100字，LLM生成）';
comment on column public.uscis_data_categories.representative_infos is '代表性数据项的 info 字段列表';
comment on column public.uscis_data_categories.item_count is '该类别下的数据项数量';

create table public.uscis_data_library_items (
                                                 tableoid oid not null,
                                                 cmax cid not null,
                                                 xmax xid not null,
                                                 cmin cid not null,
                                                 xmin xid not null,
                                                 ctid tid not null,
                                                 id integer primary key not null default nextval('uscis_data_library_items_id_seq'::regclass),
                                                 topic character varying(500) not null, -- 数据项标题，如 "Form I-485 Quarterly Report (FY2024 Q1)"
                                                 categories json not null, -- 分类列表，每项包含 main 和 sub 字段，一个数据可属于多个类别
                                                 data_date character varying(100), -- 数据日期字符串，如 "June 30, 2024"
                                                 file_type character varying(20) not null, -- 文件类型：PDF, CSV, EXCEL
                                                 info text, -- 数据描述/介绍
                                                 link text not null, -- 原始数据文件链接（唯一标识）
                                                 markdown_content text, -- 解析后的 Markdown 表格内容
                                                 content_length integer not null, -- markdown_content 字符长度
                                                 naming_pattern character varying(200), -- 命名模式标识，如 "I-485 Quarterly Report"
                                                 created_at timestamp with time zone not null,
                                                 updated_at timestamp with time zone not null,
                                                 excel_sheets json -- Excel子表列表，每项包含sheet_name/summary/content/row_count/col_count
);
create unique index idx_data_library_link on uscis_data_library_items using btree (link);
create index idx_data_library_naming_pattern on uscis_data_library_items using btree (naming_pattern);
create index idx_data_library_topic on uscis_data_library_items using btree (topic);
create unique index ix_uscis_data_library_items_link on uscis_data_library_items using btree (link);
create index ix_uscis_data_library_items_naming_pattern on uscis_data_library_items using btree (naming_pattern);
create index ix_uscis_data_library_items_topic on uscis_data_library_items using btree (topic);
comment on column public.uscis_data_library_items.topic is '数据项标题，如 "Form I-485 Quarterly Report (FY2024 Q1)"';
comment on column public.uscis_data_library_items.categories is '分类列表，每项包含 main 和 sub 字段，一个数据可属于多个类别';
comment on column public.uscis_data_library_items.data_date is '数据日期字符串，如 "June 30, 2024"';
comment on column public.uscis_data_library_items.file_type is '文件类型：PDF, CSV, EXCEL';
comment on column public.uscis_data_library_items.info is '数据描述/介绍';
comment on column public.uscis_data_library_items.link is '原始数据文件链接（唯一标识）';
comment on column public.uscis_data_library_items.markdown_content is '解析后的 Markdown 表格内容';
comment on column public.uscis_data_library_items.content_length is 'markdown_content 字符长度';
comment on column public.uscis_data_library_items.naming_pattern is '命名模式标识，如 "I-485 Quarterly Report"';
comment on column public.uscis_data_library_items.excel_sheets is 'Excel子表列表，每项包含sheet_name/summary/content/row_count/col_count';

create table public.uscis_form_fees (
                                        tableoid oid not null,
                                        cmax cid not null,
                                        xmax xid not null,
                                        cmin cid not null,
                                        xmin xid not null,
                                        ctid tid not null,
                                        id integer primary key not null default nextval('uscis_form_fees_id_seq'::regclass),
                                        form_marker character varying(100) not null, -- 表格标识符，例如：imm-fee, i-485
                                        form_name character varying(500) not null, -- 表格名称，例如：USCIS Immigrant Fee
                                        form_number character varying(50), -- 表格编号，例如：I-485
                                        edition_date character varying(50), -- 版本日期字符串，例如：01/01/2024
                                        edition_date_parsed timestamp with time zone not null, -- 解析后的版本日期（用于查询和比较）
                                        raw_html_content text, -- 原始HTML内容，包含表格费用信息的完整HTML
                                        full_url character varying(500), -- 完整的页面URL，例如：https://www.uscis.gov/g-1055?form=i-485
                                        created_at timestamp with time zone not null default now(),
                                        updated_at timestamp with time zone not null default now()
);
create index idx_form_fees_form_marker on uscis_form_fees using btree (form_marker);
create index idx_form_fees_edition_date on uscis_form_fees using btree (edition_date_parsed);
create index ix_uscis_form_fees_edition_date_parsed on uscis_form_fees using btree (edition_date_parsed);
create unique index ix_uscis_form_fees_form_marker on uscis_form_fees using btree (form_marker);
comment on column public.uscis_form_fees.form_marker is '表格标识符，例如：imm-fee, i-485';
comment on column public.uscis_form_fees.form_name is '表格名称，例如：USCIS Immigrant Fee';
comment on column public.uscis_form_fees.form_number is '表格编号，例如：I-485';
comment on column public.uscis_form_fees.edition_date is '版本日期字符串，例如：01/01/2024';
comment on column public.uscis_form_fees.edition_date_parsed is '解析后的版本日期（用于查询和比较）';
comment on column public.uscis_form_fees.raw_html_content is '原始HTML内容，包含表格费用信息的完整HTML';
comment on column public.uscis_form_fees.full_url is '完整的页面URL，例如：https://www.uscis.gov/g-1055?form=i-485';

create table public.uscis_forms (
                                    tableoid oid not null,
                                    cmax cid not null,
                                    xmax xid not null,
                                    cmin cid not null,
                                    xmin xid not null,
                                    ctid tid not null,
                                    id integer primary key not null default nextval('uscis_forms_id_seq'::regclass),
                                    form_marker character varying(100) not null, -- 表格标识符，例如：eoir-29, i-485，用于关联费用表格
                                    form_number character varying(50), -- 表格编号，例如：EOIR-29, I-485
                                    form_name character varying(500) not null, -- 表格名称，例如：EOIR-29 | Notice of Appeal...
                                    form_categories json, -- 表格类别列表，例如：["Family-Based Forms", "Employment-Based Forms"]
                                    short_description text, -- 简短描述（从列表页提取）
                                    detailed_description text, -- 详细描述（从详情页提取）
                                    full_url character varying(500) not null, -- 完整的表格详情页URL，例如：https://www.uscis.gov/eoir-29
                                    fee_form_marker character varying(100), -- 费用表格标识符，例如：eoir-29, i-485，用于关联费用表格
                                    form_pdf_urls json, -- 申请表格PDF链接列表，格式：[{"url": "/sites/.../i-854a.pdf", "full_url": "https://...", "filename": "i-854a.pdf", "size": "1.44 MB"}]
                                    form_infra_pdf_url json, -- 表格说明文件PDF链接，格式：{"url": "/sites/.../i-485-instr.pdf", "full_url": "https://...", "filename": "i-485-instr.pdf", "size": "2.1 MB"}
                                    other_pdf_urls json, -- 其他相关PDF链接列表（补充材料、附件等），格式：[{"url": "...", "filename": "...", "size": "...", "description": "..."}]
                                    edition_date character varying(50), -- 版本日期字符串，例如：07/01/25
                                    edition_date_parsed timestamp with time zone, -- 解析后的版本日期
                                    created_at timestamp with time zone not null default now(),
                                    updated_at timestamp with time zone not null default now(),
                                    form_summary text -- 表格内容的LLM生成摘要（英文，包含目的、资格、关键部分等）
);
create index idx_forms_form_marker on uscis_forms using btree (form_marker);
create index idx_forms_form_number on uscis_forms using btree (form_number);
create index idx_forms_edition_date on uscis_forms using btree (edition_date_parsed);
create index ix_uscis_forms_edition_date_parsed on uscis_forms using btree (edition_date_parsed);
create unique index ix_uscis_forms_form_marker on uscis_forms using btree (form_marker);
create index ix_uscis_forms_form_number on uscis_forms using btree (form_number);
comment on column public.uscis_forms.form_marker is '表格标识符，例如：eoir-29, i-485，用于关联费用表格';
comment on column public.uscis_forms.form_number is '表格编号，例如：EOIR-29, I-485';
comment on column public.uscis_forms.form_name is '表格名称，例如：EOIR-29 | Notice of Appeal...';
comment on column public.uscis_forms.form_categories is '表格类别列表，例如：["Family-Based Forms", "Employment-Based Forms"]';
comment on column public.uscis_forms.short_description is '简短描述（从列表页提取）';
comment on column public.uscis_forms.detailed_description is '详细描述（从详情页提取）';
comment on column public.uscis_forms.full_url is '完整的表格详情页URL，例如：https://www.uscis.gov/eoir-29';
comment on column public.uscis_forms.fee_form_marker is '费用表格标识符，例如：eoir-29, i-485，用于关联费用表格';
comment on column public.uscis_forms.form_pdf_urls is '申请表格PDF链接列表，格式：[{"url": "/sites/.../i-854a.pdf", "full_url": "https://...", "filename": "i-854a.pdf", "size": "1.44 MB"}]';
comment on column public.uscis_forms.form_infra_pdf_url is '表格说明文件PDF链接，格式：{"url": "/sites/.../i-485-instr.pdf", "full_url": "https://...", "filename": "i-485-instr.pdf", "size": "2.1 MB"}';
comment on column public.uscis_forms.other_pdf_urls is '其他相关PDF链接列表（补充材料、附件等），格式：[{"url": "...", "filename": "...", "size": "...", "description": "..."}]';
comment on column public.uscis_forms.edition_date is '版本日期字符串，例如：07/01/25';
comment on column public.uscis_forms.edition_date_parsed is '解析后的版本日期';
comment on column public.uscis_forms.form_summary is '表格内容的LLM生成摘要（英文，包含目的、资格、关键部分等）';

create table public.user_beta_profiles (
                                           tableoid oid not null,
                                           cmax cid not null,
                                           xmax xid not null,
                                           cmin cid not null,
                                           xmin xid not null,
                                           ctid tid not null,
                                           id integer primary key not null default nextval('user_beta_profiles_id_seq'::regclass),
                                           user_id character varying(36) not null, -- 关联的用户ID
                                           status betastatus not null, -- 内测状态: unapplied, waiting, active, banned
                                           activation_source activationsource, -- 激活来源: queue(排队), invite(邀请), manual(人工)
                                           invite_quota integer not null, -- 剩余邀请名额
                                           invite_code_id integer, -- 使用的邀请码ID（如果是被邀请开通）
                                           applied_at timestamp with time zone, -- 申请时间（用于排队顺序）
                                           activated_at timestamp with time zone, -- 激活时间
                                           activation_msg_subscribed boolean not null, -- 是否已订阅激活通知消息
                                           reminder_msg_subscribed boolean not null, -- 是否已订阅次日提醒消息
                                           activation_notified boolean not null, -- 是否已发送激活通知
                                           reminder_notified boolean not null, -- 是否已发送次日提醒
                                           created_at timestamp with time zone not null,
                                           updated_at timestamp with time zone not null,
                                           foreign key (invite_code_id) references public.invite_codes (id)
                                               match simple on update no action on delete no action,
                                           foreign key (user_id) references public.users (id)
                                               match simple on update no action on delete no action
);
create index idx_beta_profile_invite_code_id on user_beta_profiles using btree (invite_code_id);
create index idx_beta_profile_status on user_beta_profiles using btree (status);
create index idx_beta_profile_status_applied on user_beta_profiles using btree (status, applied_at);
create unique index idx_beta_profile_user_id on user_beta_profiles using btree (user_id);
create index ix_user_beta_profiles_activated_at on user_beta_profiles using btree (activated_at);
create index ix_user_beta_profiles_applied_at on user_beta_profiles using btree (applied_at);
create index ix_user_beta_profiles_invite_code_id on user_beta_profiles using btree (invite_code_id);
create index ix_user_beta_profiles_status on user_beta_profiles using btree (status);
create unique index ix_user_beta_profiles_user_id on user_beta_profiles using btree (user_id);
comment on column public.user_beta_profiles.user_id is '关联的用户ID';
comment on column public.user_beta_profiles.status is '内测状态: unapplied, waiting, active, banned';
comment on column public.user_beta_profiles.activation_source is '激活来源: queue(排队), invite(邀请), manual(人工)';
comment on column public.user_beta_profiles.invite_quota is '剩余邀请名额';
comment on column public.user_beta_profiles.invite_code_id is '使用的邀请码ID（如果是被邀请开通）';
comment on column public.user_beta_profiles.applied_at is '申请时间（用于排队顺序）';
comment on column public.user_beta_profiles.activated_at is '激活时间';
comment on column public.user_beta_profiles.activation_msg_subscribed is '是否已订阅激活通知消息';
comment on column public.user_beta_profiles.reminder_msg_subscribed is '是否已订阅次日提醒消息';
comment on column public.user_beta_profiles.activation_notified is '是否已发送激活通知';
comment on column public.user_beta_profiles.reminder_notified is '是否已发送次日提醒';

create table public.users (
                              tableoid oid not null,
                              cmax cid not null,
                              xmax xid not null,
                              cmin cid not null,
                              xmin xid not null,
                              ctid tid not null,
                              id character varying(36) primary key not null,
                              auth_provider authprovider not null, -- 用户认证来源: wechat 等
                              openid character varying(64),
                              unionid character varying(64),
                              created_at timestamp with time zone not null,
                              last_login_at timestamp with time zone not null,
                              phone_number character varying(20), -- 手机号（不含国家码）
                              phone_country_code character varying(10), -- 手机号国家码，如 86（中国大陆），绑定手机号时填写
                              identity_type identitytype, -- 身份类型: individual(个人), agency(中介/机构)
                              nickname character varying(100), -- 用户昵称（微信昵称或自定义）
                              avatar_url character varying(500), -- 用户头像 URL
                              agency_name character varying(200), -- 机构名称
                              annual_clients integer, -- 年均客户数
                              is_active boolean not null default false, -- 是否为 ACTIVE 状态（与 beta_profile.status 同步）
                              updated_at timestamp with time zone not null default now()
);
create index idx_users_auth_provider on users using btree (auth_provider);
create unique index idx_users_openid on users using btree (openid);
create unique index idx_users_unionid on users using btree (unionid);
create index ix_users_auth_provider on users using btree (auth_provider);
create unique index ix_users_openid on users using btree (openid);
create unique index ix_users_unionid on users using btree (unionid);
create index idx_users_is_active on users using btree (is_active);
create unique index idx_users_phone_number on users using btree (phone_number);
create index ix_users_is_active on users using btree (is_active);
create unique index ix_users_phone_number on users using btree (phone_number);
comment on column public.users.auth_provider is '用户认证来源: wechat 等';
comment on column public.users.phone_number is '手机号（不含国家码）';
comment on column public.users.phone_country_code is '手机号国家码，如 86（中国大陆），绑定手机号时填写';
comment on column public.users.identity_type is '身份类型: individual(个人), agency(中介/机构)';
comment on column public.users.nickname is '用户昵称（微信昵称或自定义）';
comment on column public.users.avatar_url is '用户头像 URL';
comment on column public.users.agency_name is '机构名称';
comment on column public.users.annual_clients is '年均客户数';
comment on column public.users.is_active is '是否为 ACTIVE 状态（与 beta_profile.status 同步）';

create table public.visa_bulletin_data (
                                           tableoid oid not null,
                                           cmax cid not null,
                                           xmax xid not null,
                                           cmin cid not null,
                                           xmin xid not null,
                                           ctid tid not null,
                                           year integer not null,
                                           month integer not null,
                                           fiscal_year integer, -- 财政年度，例如：2025表示FY2025
                                           visa_bulletin_content text, -- Visa Bulletin 原始内容（Markdown格式）
                                           visa_bulletin_url character varying(500), -- Visa Bulletin 页面URL
                                           family_form character varying(2), -- Family类别使用的表格: A或B
                                           employment_form character varying(2), -- Employment类别使用的表格: A或B
                                           created_at timestamp with time zone not null default now(),
                                           updated_at timestamp with time zone not null default now(),
                                           primary key (year, month)
);
comment on column public.visa_bulletin_data.fiscal_year is '财政年度，例如：2025表示FY2025';
comment on column public.visa_bulletin_data.visa_bulletin_content is 'Visa Bulletin 原始内容（Markdown格式）';
comment on column public.visa_bulletin_data.visa_bulletin_url is 'Visa Bulletin 页面URL';
comment on column public.visa_bulletin_data.family_form is 'Family类别使用的表格: A或B';
comment on column public.visa_bulletin_data.employment_form is 'Employment类别使用的表格: A或B';

create table public.visa_monthly_issuances (
                                               tableoid oid not null,
                                               cmax cid not null,
                                               xmax xid not null,
                                               cmin cid not null,
                                               xmin xid not null,
                                               ctid tid not null,
                                               id integer primary key not null default nextval('visa_monthly_issuances_id_seq'::regclass),
                                               fiscal_year integer not null, -- 财年（10月开始），如 2024 表示 FY2024
                                               year integer not null, -- 自然年
                                               month integer not null, -- 月份 (1-12)
                                               visa_type character varying(10) not null, -- 签证大类: IV (移民签证) 或 NIV (非移民签证)
                                               dimension_type character varying(20) not null, -- 维度类型: fsc (出生国/收费国), post (领事馆), nationality (国籍)
                                               dimension_value character varying(200) not null, -- 维度值: 国家名、领事馆名等
                                               visa_class character varying(50) not null, -- 签证类别代码: EB-1, F-1, H-1B, IR1, CR1 等
                                               issuance_count integer not null, -- 签证发放数量
                                               source_url text, -- 原始数据文件 URL
                                               source_file character varying(300), -- 原始数据文件名
                                               created_at timestamp with time zone not null,
                                               updated_at timestamp with time zone not null
);
create unique index uq_visa_monthly_record on visa_monthly_issuances using btree (fiscal_year, year, month, visa_type, dimension_type, dimension_value, visa_class);
create index idx_visa_monthly_dim_value on visa_monthly_issuances using btree (dimension_type, dimension_value);
create index idx_visa_monthly_fy_type on visa_monthly_issuances using btree (fiscal_year, visa_type);
create index idx_visa_monthly_fy_type_dim on visa_monthly_issuances using btree (fiscal_year, visa_type, dimension_type);
create index idx_visa_monthly_visa_class on visa_monthly_issuances using btree (visa_class);
create index ix_visa_monthly_issuances_dimension_type on visa_monthly_issuances using btree (dimension_type);
create index ix_visa_monthly_issuances_dimension_value on visa_monthly_issuances using btree (dimension_value);
create index ix_visa_monthly_issuances_fiscal_year on visa_monthly_issuances using btree (fiscal_year);
create index ix_visa_monthly_issuances_month on visa_monthly_issuances using btree (month);
create index ix_visa_monthly_issuances_visa_class on visa_monthly_issuances using btree (visa_class);
create index ix_visa_monthly_issuances_visa_type on visa_monthly_issuances using btree (visa_type);
create index ix_visa_monthly_issuances_year on visa_monthly_issuances using btree (year);
comment on column public.visa_monthly_issuances.fiscal_year is '财年（10月开始），如 2024 表示 FY2024';
comment on column public.visa_monthly_issuances.year is '自然年';
comment on column public.visa_monthly_issuances.month is '月份 (1-12)';
comment on column public.visa_monthly_issuances.visa_type is '签证大类: IV (移民签证) 或 NIV (非移民签证)';
comment on column public.visa_monthly_issuances.dimension_type is '维度类型: fsc (出生国/收费国), post (领事馆), nationality (国籍)';
comment on column public.visa_monthly_issuances.dimension_value is '维度值: 国家名、领事馆名等';
comment on column public.visa_monthly_issuances.visa_class is '签证类别代码: EB-1, F-1, H-1B, IR1, CR1 等';
comment on column public.visa_monthly_issuances.issuance_count is '签证发放数量';
comment on column public.visa_monthly_issuances.source_url is '原始数据文件 URL';
comment on column public.visa_monthly_issuances.source_file is '原始数据文件名';

create table public.visa_statistics_files (
                                              tableoid oid not null,
                                              cmax cid not null,
                                              xmax xid not null,
                                              cmin cid not null,
                                              xmin xid not null,
                                              ctid tid not null,
                                              id integer primary key not null default nextval('visa_statistics_files_id_seq'::regclass),
                                              file_key character varying(300) not null, -- 文件唯一标识符，LLM用来引用，格式: category/subcategory/filename_stem
                                              category character varying(50) not null, -- 一级分类: annual_reports, iv_statistics, niv_statistics
                                              subcategory character varying(50) not null, -- 二级分类: FY2024, family_preference_cutoff, detail_tables 等
                                              filename character varying(300) not null, -- 原始文件名(不含路径)
                                              file_type character varying(20) not null, -- 文件类型: pdf, xlsx, md
                                              fiscal_year_start integer, -- 数据起始财年, 如 2020
                                              fiscal_year_end integer, -- 数据结束财年, 如 2024 (多年报告用)
                                              table_number character varying(20), -- 表格编号: I, II, III, ..., XIX, XX 或 A, B (附录)
                                              title character varying(500), -- 文件标题/描述，用于展示和搜索
                                              markdown_content text, -- 解析后的 Markdown 内容
                                              content_length integer not null, -- markdown_content 字符长度
                                              source_url text, -- 原始下载 URL
                                              created_at timestamp with time zone not null,
                                              updated_at timestamp with time zone not null
);
create index idx_visa_file_category_sub on visa_statistics_files using btree (category, subcategory);
create index idx_visa_file_fy_range on visa_statistics_files using btree (fiscal_year_start, fiscal_year_end);
create unique index idx_visa_file_key on visa_statistics_files using btree (file_key);
create index idx_visa_file_table on visa_statistics_files using btree (table_number);
create index ix_visa_statistics_files_category on visa_statistics_files using btree (category);
create unique index ix_visa_statistics_files_file_key on visa_statistics_files using btree (file_key);
create index ix_visa_statistics_files_filename on visa_statistics_files using btree (filename);
create index ix_visa_statistics_files_fiscal_year_start on visa_statistics_files using btree (fiscal_year_start);
create index ix_visa_statistics_files_source_url on visa_statistics_files using btree (source_url);
create index ix_visa_statistics_files_subcategory on visa_statistics_files using btree (subcategory);
create index ix_visa_statistics_files_table_number on visa_statistics_files using btree (table_number);
comment on column public.visa_statistics_files.file_key is '文件唯一标识符，LLM用来引用，格式: category/subcategory/filename_stem';
comment on column public.visa_statistics_files.category is '一级分类: annual_reports, iv_statistics, niv_statistics';
comment on column public.visa_statistics_files.subcategory is '二级分类: FY2024, family_preference_cutoff, detail_tables 等';
comment on column public.visa_statistics_files.filename is '原始文件名(不含路径)';
comment on column public.visa_statistics_files.file_type is '文件类型: pdf, xlsx, md';
comment on column public.visa_statistics_files.fiscal_year_start is '数据起始财年, 如 2020';
comment on column public.visa_statistics_files.fiscal_year_end is '数据结束财年, 如 2024 (多年报告用)';
comment on column public.visa_statistics_files.table_number is '表格编号: I, II, III, ..., XIX, XX 或 A, B (附录)';
comment on column public.visa_statistics_files.title is '文件标题/描述，用于展示和搜索';
comment on column public.visa_statistics_files.markdown_content is '解析后的 Markdown 内容';
comment on column public.visa_statistics_files.content_length is 'markdown_content 字符长度';
comment on column public.visa_statistics_files.source_url is '原始下载 URL';


```