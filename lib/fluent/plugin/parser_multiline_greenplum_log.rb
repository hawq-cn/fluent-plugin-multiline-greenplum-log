#
# Copyright 2018- Violet Cheng
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/parser"

module Fluent
  module Plugin
    class MultilineGreenplumLogParser < Fluent::Plugin::Parser
      Fluent::Plugin.register_parser("multiline_greenplum_log", self)
      config_param :format_firstline, :string, :default => '/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{6} \w{3},\S*,\S*,/'
      config_param :keys, :array, default: ['timestamp','user_name','database_name','process_id',
      'thread_id','remote_host','remote_port','session_start_time','transaction_id','session_id','command_cnt','segment_id','slice_id','dist_trans_id','local_trans_id','subtrans_id','error_severity','sql_state_code','message','detail','hint','internal_query','internal_query_pos','error_context','user_query','cursor_pos','function_name','file_name','line_number','stack_trace']
      def initialize
        super
        require 'csv'
      end
      def configure(conf)
        super
        if @format_firstline
          check_format_regexp(@format_firstline, 'format_firstline')
          @firstline_regex = Regexp.new(@format_firstline[1..-2])
        end
      end

      def values_map(values)
        record = Hash[keys.zip(values.map { |value| convert_value_to_nil(value) })]

        if @time_key
          value = @keep_time_key ? record[@time_key] : record.delete(@time_key)
          time = if value.nil?
                   if @estimate_current_event
                     Fluent::EventTime.now
                   else
                     nil
                   end
                 else
                   @mutex.synchronize { @time_parser.parse(value) }
                 end
        elsif @estimate_current_event
          time = Fluent::EventTime.now
        else
          time = nil
        end

        convert_field_type!(record) if @type_converters

        return time, record
      end
      
      
      def parse(text)
        if block_given?
          yield values_map(CSV.parse_line(text))
        else
          return values_map(CSV.parse_line(text))
        end
      end

      def has_firstline?
        !!@format_firstline
      end
      def firstline?(text)
        @firstline_regex.match(text)
      end
      private
      def check_format_regexp(format, key)
        if format[0] == '/' && format[-1] == '/'
          begin
            Regexp.new(format[1..-2])
          rescue => e
            raise ConfigError, "Invalid regexp in #{key}: #{e}"
          end
        else
          raise ConfigError, "format_firstline should be Regexp, need //: '#{format}'"
        end
      end

      def convert_field_type!(record)
        @type_converters.each_key { |key|
          if value = record[key]
            record[key] = convert_type(key, value)
          end
        }
      end

      def convert_value_to_nil(value)
        if value and @null_empty_string
          value = (value == '') ? nil : value
        end
        if value and @null_value_pattern
          value = ::Fluent::StringUtil.match_regexp(@null_value_pattern, value) ? nil : value
        end
        value
      end
    end
  end
end
