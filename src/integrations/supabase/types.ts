export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      agent_messages: {
        Row: {
          agent_name: string
          body: string | null
          channel: string
          created_at: string
          customer_id: string | null
          delivered_via: string | null
          id: string
          invoice_ids: string[] | null
          metadata: Json | null
          recipient_email: string | null
          recipient_name: string | null
          recipient_type: string | null
          run_id: string
          status: string | null
          subject: string | null
          template_type: string | null
        }
        Insert: {
          agent_name: string
          body?: string | null
          channel?: string
          created_at?: string
          customer_id?: string | null
          delivered_via?: string | null
          id?: string
          invoice_ids?: string[] | null
          metadata?: Json | null
          recipient_email?: string | null
          recipient_name?: string | null
          recipient_type?: string | null
          run_id: string
          status?: string | null
          subject?: string | null
          template_type?: string | null
        }
        Update: {
          agent_name?: string
          body?: string | null
          channel?: string
          created_at?: string
          customer_id?: string | null
          delivered_via?: string | null
          id?: string
          invoice_ids?: string[] | null
          metadata?: Json | null
          recipient_email?: string | null
          recipient_name?: string | null
          recipient_type?: string | null
          run_id?: string
          status?: string | null
          subject?: string | null
          template_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "agent_messages_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "agent_messages_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      agent_runs: {
        Row: {
          actions_taken: number | null
          agent_name: string
          completed_at: string | null
          conditions_found: number | null
          customers_scanned: number | null
          id: string
          messages_composed: number | null
          run_id: string
          started_at: string
          status: string
          summary: string | null
          triggered_by: string | null
        }
        Insert: {
          actions_taken?: number | null
          agent_name: string
          completed_at?: string | null
          conditions_found?: number | null
          customers_scanned?: number | null
          id?: string
          messages_composed?: number | null
          run_id: string
          started_at?: string
          status?: string
          summary?: string | null
          triggered_by?: string | null
        }
        Update: {
          actions_taken?: number | null
          agent_name?: string
          completed_at?: string | null
          conditions_found?: number | null
          customers_scanned?: number | null
          id?: string
          messages_composed?: number | null
          run_id?: string
          started_at?: string
          status?: string
          summary?: string | null
          triggered_by?: string | null
        }
        Relationships: []
      }
      ar_aging_snapshots: {
        Row: {
          as_of_date: string
          created_at: string
          credit_limit: number | null
          current_amount: number | null
          customer_id: string
          days_1_30: number | null
          days_31_60: number | null
          days_61_90: number | null
          days_over_90: number | null
          dso: number | null
          id: string
          risk_tier: string | null
          total_ar: number | null
          utilization_pct: number | null
        }
        Insert: {
          as_of_date?: string
          created_at?: string
          credit_limit?: number | null
          current_amount?: number | null
          customer_id: string
          days_1_30?: number | null
          days_31_60?: number | null
          days_61_90?: number | null
          days_over_90?: number | null
          dso?: number | null
          id?: string
          risk_tier?: string | null
          total_ar?: number | null
          utilization_pct?: number | null
        }
        Update: {
          as_of_date?: string
          created_at?: string
          credit_limit?: number | null
          current_amount?: number | null
          customer_id?: string
          days_1_30?: number | null
          days_31_60?: number | null
          days_61_90?: number | null
          days_over_90?: number | null
          dso?: number | null
          id?: string
          risk_tier?: string | null
          total_ar?: number | null
          utilization_pct?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "ar_aging_snapshots_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ar_aging_snapshots_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      bankruptcy_details: {
        Row: {
          chapter: string | null
          created_at: string
          customer_id: string
          details: string | null
          filing_date: string | null
          id: string
          status: string | null
        }
        Insert: {
          chapter?: string | null
          created_at?: string
          customer_id: string
          details?: string | null
          filing_date?: string | null
          id?: string
          status?: string | null
        }
        Update: {
          chapter?: string | null
          created_at?: string
          customer_id?: string
          details?: string | null
          filing_date?: string | null
          id?: string
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bankruptcy_details_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bankruptcy_details_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      company: {
        Row: {
          created_at: string
          description: string | null
          id: string
          industry: string | null
          name: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          industry?: string | null
          name: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          industry?: string | null
          name?: string
        }
        Relationships: []
      }
      credit_actions: {
        Row: {
          action_date: string | null
          action_type: string
          agent_name: string | null
          created_at: string
          customer_id: string
          description: string | null
          id: string
          status: string | null
        }
        Insert: {
          action_date?: string | null
          action_type: string
          agent_name?: string | null
          created_at?: string
          customer_id: string
          description?: string | null
          id?: string
          status?: string | null
        }
        Update: {
          action_date?: string | null
          action_type?: string
          agent_name?: string | null
          created_at?: string
          customer_id?: string
          description?: string | null
          id?: string
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "credit_actions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credit_actions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      credit_events: {
        Row: {
          agent_name: string | null
          created_at: string
          customer_id: string
          description: string | null
          event_type: string
          id: string
          severity: string | null
        }
        Insert: {
          agent_name?: string | null
          created_at?: string
          customer_id: string
          description?: string | null
          event_type: string
          id?: string
          severity?: string | null
        }
        Update: {
          agent_name?: string | null
          created_at?: string
          customer_id?: string
          description?: string | null
          event_type?: string
          id?: string
          severity?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "credit_events_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credit_events_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      credit_metrics: {
        Row: {
          altman_z_score: number | null
          credit_score: number | null
          current_ratio: number | null
          customer_id: string
          d_and_b_rating: string | null
          id: string
          updated_at: string
        }
        Insert: {
          altman_z_score?: number | null
          credit_score?: number | null
          current_ratio?: number | null
          customer_id: string
          d_and_b_rating?: string | null
          id?: string
          updated_at?: string
        }
        Update: {
          altman_z_score?: number | null
          credit_score?: number | null
          current_ratio?: number | null
          customer_id?: string
          d_and_b_rating?: string | null
          id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "credit_metrics_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "credit_metrics_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      customers: {
        Row: {
          account_manager: string | null
          company_id: string | null
          company_name: string
          created_at: string
          credit_limit: number | null
          current_exposure: number | null
          flags: string[] | null
          id: string
          industry: string | null
          last_reviewed_at: string | null
          notes: string | null
          payment_terms_days: number | null
          scenario: string | null
          ticker: string | null
          updated_at: string
        }
        Insert: {
          account_manager?: string | null
          company_id?: string | null
          company_name: string
          created_at?: string
          credit_limit?: number | null
          current_exposure?: number | null
          flags?: string[] | null
          id?: string
          industry?: string | null
          last_reviewed_at?: string | null
          notes?: string | null
          payment_terms_days?: number | null
          scenario?: string | null
          ticker?: string | null
          updated_at?: string
        }
        Update: {
          account_manager?: string | null
          company_id?: string | null
          company_name?: string
          created_at?: string
          credit_limit?: number | null
          current_exposure?: number | null
          flags?: string[] | null
          id?: string
          industry?: string | null
          last_reviewed_at?: string | null
          notes?: string | null
          payment_terms_days?: number | null
          scenario?: string | null
          ticker?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "customers_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "company"
            referencedColumns: ["id"]
          },
        ]
      }
      growth_signals: {
        Row: {
          created_at: string
          customer_id: string
          description: string | null
          detected_at: string | null
          id: string
          signal_type: string
        }
        Insert: {
          created_at?: string
          customer_id: string
          description?: string | null
          detected_at?: string | null
          id?: string
          signal_type: string
        }
        Update: {
          created_at?: string
          customer_id?: string
          description?: string | null
          detected_at?: string | null
          id?: string
          signal_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "growth_signals_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "growth_signals_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      invoices: {
        Row: {
          amount: number
          created_at: string
          customer_id: string
          days_overdue: number | null
          due_date: string
          dunning_level: number | null
          id: string
          invoice_date: string
          invoice_number: string
          outstanding_amount: number | null
          paid_amount: number
          status: string | null
        }
        Insert: {
          amount?: number
          created_at?: string
          customer_id: string
          days_overdue?: number | null
          due_date: string
          dunning_level?: number | null
          id?: string
          invoice_date?: string
          invoice_number: string
          outstanding_amount?: number | null
          paid_amount?: number
          status?: string | null
        }
        Update: {
          amount?: number
          created_at?: string
          customer_id?: string
          days_overdue?: number | null
          due_date?: string
          dunning_level?: number | null
          id?: string
          invoice_date?: string
          invoice_number?: string
          outstanding_amount?: number | null
          paid_amount?: number
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "invoices_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invoices_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      negative_news: {
        Row: {
          agent_name: string | null
          category: string | null
          created_at: string
          customer_id: string
          headline: string
          id: string
          news_date: string
          reviewed: boolean | null
          reviewed_at: string | null
          reviewed_by: string | null
          sentiment_score: number | null
          severity: string | null
          source: string | null
          summary: string | null
        }
        Insert: {
          agent_name?: string | null
          category?: string | null
          created_at?: string
          customer_id: string
          headline: string
          id?: string
          news_date?: string
          reviewed?: boolean | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          sentiment_score?: number | null
          severity?: string | null
          source?: string | null
          summary?: string | null
        }
        Update: {
          agent_name?: string | null
          category?: string | null
          created_at?: string
          customer_id?: string
          headline?: string
          id?: string
          news_date?: string
          reviewed?: boolean | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          sentiment_score?: number | null
          severity?: string | null
          source?: string | null
          summary?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "negative_news_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "negative_news_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      payment_transactions: {
        Row: {
          amount: number
          created_at: string
          customer_id: string
          days_early_late: number | null
          days_to_pay: number | null
          id: string
          invoice_id: string | null
          on_time: boolean | null
          payment_date: string
          payment_method: string | null
        }
        Insert: {
          amount: number
          created_at?: string
          customer_id: string
          days_early_late?: number | null
          days_to_pay?: number | null
          id?: string
          invoice_id?: string | null
          on_time?: boolean | null
          payment_date: string
          payment_method?: string | null
        }
        Update: {
          amount?: number
          created_at?: string
          customer_id?: string
          days_early_late?: number | null
          days_to_pay?: number | null
          id?: string
          invoice_id?: string | null
          on_time?: boolean | null
          payment_date?: string
          payment_method?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "payment_transactions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_transactions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_transactions_invoice_id_fkey"
            columns: ["invoice_id"]
            isOneToOne: false
            referencedRelation: "invoices"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_transactions_invoice_id_fkey"
            columns: ["invoice_id"]
            isOneToOne: false
            referencedRelation: "v_overdue_invoices"
            referencedColumns: ["id"]
          },
        ]
      }
      pending_actions: {
        Row: {
          action_type: string
          agent_name: string
          created_at: string
          current_value: number | null
          customer_id: string | null
          expires_at: string | null
          id: string
          message_id: string | null
          proposed_value: number | null
          rationale: string | null
          review_note: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          run_id: string
          status: string
        }
        Insert: {
          action_type: string
          agent_name: string
          created_at?: string
          current_value?: number | null
          customer_id?: string | null
          expires_at?: string | null
          id?: string
          message_id?: string | null
          proposed_value?: number | null
          rationale?: string | null
          review_note?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          run_id: string
          status?: string
        }
        Update: {
          action_type?: string
          agent_name?: string
          created_at?: string
          current_value?: number | null
          customer_id?: string | null
          expires_at?: string | null
          id?: string
          message_id?: string | null
          proposed_value?: number | null
          rationale?: string | null
          review_note?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          run_id?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "pending_actions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pending_actions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pending_actions_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "agent_messages"
            referencedColumns: ["id"]
          },
        ]
      }
      sec_filings: {
        Row: {
          agent_name: string | null
          created_at: string
          customer_id: string
          filing_date: string
          filing_type: string
          id: string
          key_findings: string | null
          reviewed: boolean | null
          reviewed_at: string | null
          reviewed_by: string | null
          risk_signals: string[] | null
        }
        Insert: {
          agent_name?: string | null
          created_at?: string
          customer_id: string
          filing_date: string
          filing_type: string
          id?: string
          key_findings?: string | null
          reviewed?: boolean | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          risk_signals?: string[] | null
        }
        Update: {
          agent_name?: string | null
          created_at?: string
          customer_id?: string
          filing_date?: string
          filing_type?: string
          id?: string
          key_findings?: string | null
          reviewed?: boolean | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          risk_signals?: string[] | null
        }
        Relationships: [
          {
            foreignKeyName: "sec_filings_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sec_filings_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      sec_monitoring: {
        Row: {
          ai_risk_score: number | null
          ai_summary: string | null
          alert_triggered: boolean | null
          cik: string | null
          created_at: string
          customer_id: string
          id: string
          last_10k_date: string | null
          last_10q_date: string | null
          risk_signals: string[] | null
        }
        Insert: {
          ai_risk_score?: number | null
          ai_summary?: string | null
          alert_triggered?: boolean | null
          cik?: string | null
          created_at?: string
          customer_id: string
          id?: string
          last_10k_date?: string | null
          last_10q_date?: string | null
          risk_signals?: string[] | null
        }
        Update: {
          ai_risk_score?: number | null
          ai_summary?: string | null
          alert_triggered?: boolean | null
          cik?: string | null
          created_at?: string
          customer_id?: string
          id?: string
          last_10k_date?: string | null
          last_10q_date?: string | null
          risk_signals?: string[] | null
        }
        Relationships: [
          {
            foreignKeyName: "sec_monitoring_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sec_monitoring_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      v_ar_aging_current: {
        Row: {
          as_of_date: string | null
          company_name: string | null
          created_at: string | null
          credit_limit: number | null
          current_amount: number | null
          customer_id: string | null
          days_1_30: number | null
          days_31_60: number | null
          days_61_90: number | null
          days_over_90: number | null
          dso: number | null
          id: string | null
          risk_tier: string | null
          ticker: string | null
          total_ar: number | null
          utilization_pct: number | null
        }
        Relationships: [
          {
            foreignKeyName: "ar_aging_snapshots_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ar_aging_snapshots_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      v_ar_aging_portfolio: {
        Row: {
          customer_count: number | null
          total_1_30: number | null
          total_31_60: number | null
          total_61_90: number | null
          total_ar: number | null
          total_current: number | null
          total_over_90: number | null
        }
        Relationships: []
      }
      v_customers_at_risk: {
        Row: {
          account_manager: string | null
          altman_z_score: number | null
          company_id: string | null
          company_name: string | null
          created_at: string | null
          credit_limit: number | null
          credit_score: number | null
          current_exposure: number | null
          flags: string[] | null
          id: string | null
          industry: string | null
          last_reviewed_at: string | null
          notes: string | null
          payment_terms_days: number | null
          scenario: string | null
          ticker: string | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "customers_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "company"
            referencedColumns: ["id"]
          },
        ]
      }
      v_overdue_invoices: {
        Row: {
          amount: number | null
          company_name: string | null
          created_at: string | null
          customer_id: string | null
          days_overdue: number | null
          due_date: string | null
          dunning_level: number | null
          id: string | null
          invoice_date: string | null
          invoice_number: string | null
          outstanding_amount: number | null
          paid_amount: number | null
          status: string | null
          ticker: string | null
        }
        Relationships: [
          {
            foreignKeyName: "invoices_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invoices_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      v_payment_behaviour: {
        Row: {
          avg_days_to_pay: number | null
          company_name: string | null
          customer_id: string | null
          on_time_pct: number | null
          ticker: string | null
          total_payments: number | null
        }
        Relationships: [
          {
            foreignKeyName: "payment_transactions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payment_transactions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
      v_sec_monitoring_dashboard: {
        Row: {
          ai_risk_score: number | null
          ai_summary: string | null
          alert_triggered: boolean | null
          cik: string | null
          company_name: string | null
          created_at: string | null
          customer_id: string | null
          id: string | null
          last_10k_date: string | null
          last_10q_date: string | null
          risk_signals: string[] | null
          ticker: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sec_monitoring_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sec_monitoring_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "v_customers_at_risk"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      fn_refresh_all_ar_aging: {
        Args: { p_as_of?: string }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
