-- ============================================================
-- SEED DATA - Global Trading Solutions Inc Demo Company
-- Generated: 2026-02-27 03:14
-- Customers: 49
-- ============================================================

SET session_replication_role = replica;

-- COMPANY
INSERT INTO company (
  id, name, ticker, industry, annual_revenue, description,
  headquarters, founded, employees,
  max_single_customer_exposure_pct, standard_payment_terms_days,
  review_trigger_days_overdue, watch_list_trigger_days_overdue,
  total_portfolio_limit, base_currency, fiscal_year_end_month
) VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Global Trading Solutions Inc',
  'GTSI',
  'Specialty Alloys Distribution',
  500000000,
  'Leading distributor of specialty alloys, titanium, nickel superalloys, and high-performance metals serving aerospace, defense, energy, and industrial sectors.',
  'Houston, TX',
  1987,
  1200,
  10,
  45,
  30,
  60,
  130000000,
  'USD',
  12
) ON CONFLICT (id) DO NOTHING;

-- CUSTOMERS
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'The Boeing Company',
  'BA',
  '0000012927',
  'normal_operations',
  'Aerospace & Defense',
  'large_cap',
  98000000000,
  'Arlington, VA',
  8000000,
  5200000,
  45,
  '2008-03-15',
  'Sarah Chen',
  'James Whitfield, VP Supply Chain',
  ARRAY['Titanium 6Al-4V plate', 'Inconel 718 bar', 'Titanium 3Al-2.5V tubing'],
  '2026-12-31',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'Raytheon Technologies (RTX)',
  'RTX',
  '0000101830',
  'normal_operations',
  'Aerospace & Defense',
  'large_cap',
  142000000000,
  'Arlington, VA',
  7500000,
  4800000,
  45,
  '2005-07-22',
  'Sarah Chen',
  'Maria Santos, Director of Procurement',
  ARRAY['Inconel 625 sheet', 'Hastelloy C-276', 'Rene 41 bar stock'],
  '2027-06-30',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'Lockheed Martin Corporation',
  'LMT',
  '0000936395',
  'normal_operations',
  'Aerospace & Defense',
  'large_cap',
  105000000000,
  'Bethesda, MD',
  6500000,
  4100000,
  45,
  '2003-04-12',
  'Sarah Chen',
  'Amanda Foster, Strategic Sourcing',
  ARRAY['Titanium 6Al-4V forgings', 'Aluminum 7050 plate', 'Inconel 625 tubing'],
  '2027-03-31',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-18'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'Parker Hannifin Corporation',
  'PH',
  '0000076334',
  'normal_operations',
  'Industrial Motion & Control',
  'large_cap',
  72000000000,
  'Cleveland, OH',
  3000000,
  2200000,
  45,
  '2007-05-18',
  'Sarah Chen',
  'Carolyn Drake, Materials VP',
  ARRAY['Stainless 316L bar', 'Inconel 625 tubing', 'Titanium fittings'],
  '2027-05-31',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-02-03'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'Precision Castparts Corp',
  'PCC',
  '0000079879',
  'normal_operations',
  'Aerospace & Industrial Components',
  'large_cap',
  35000000000,
  'Portland, OR',
  5000000,
  3800000,
  45,
  '2004-06-10',
  'Sarah Chen',
  'Karen Walsh, Materials Director',
  ARRAY['Nickel superalloy billet', 'Cobalt alloy bar', 'Waspaloy'],
  '2026-12-31',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-12'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'Baker Hughes Company',
  'BKR',
  '0001701605',
  'normal_operations',
  'Oil & Gas Equipment',
  'large_cap',
  34000000000,
  'Houston, TX',
  4000000,
  2800000,
  45,
  '2005-01-10',
  'Michael Torres',
  'George Phillips, Head of Supply Chain',
  ARRAY['Inconel 625 tubing', 'Duplex 2205 pipe', 'Hastelloy C-276 fittings'],
  '2026-01-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-02-05'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'Huntington Ingalls Industries Inc',
  'HII',
  '0001501585',
  'normal_operations',
  'Naval Defense Shipbuilding',
  'mid_cap',
  7800000000,
  'Newport News, VA',
  3500000,
  2600000,
  45,
  '2011-08-15',
  'Sarah Chen',
  'John Castillo, Materials Director',
  ARRAY['HY-80 steel plate', 'Duplex 2205 plate', 'Inconel 625 weld wire'],
  '2027-08-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-02-02'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'Howmet Aerospace Inc',
  'HWM',
  '0000004281',
  'normal_operations',
  'Aerospace Components Manufacturing',
  'large_cap',
  32000000000,
  'Pittsburgh, PA',
  4500000,
  3200000,
  45,
  '2010-08-01',
  'Michael Torres',
  'David Lee, VP Materials',
  ARRAY['Nickel superalloy bar', 'Cobalt alloy castings', 'Titanium billet'],
  '2025-12-31',
  TRUE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-22'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'TransDigm Group Incorporated',
  'TDG',
  '0001260221',
  'normal_operations',
  'Aerospace Components',
  'large_cap',
  68000000000,
  'Cleveland, OH',
  3500000,
  2400000,
  45,
  '2012-02-14',
  'Michael Torres',
  'Linda Marsh, Procurement Lead',
  ARRAY['Inconel 718 bar', 'Titanium 6Al-4V plate', '15-5 PH stainless'],
  '2026-06-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-25'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'Spirit AeroSystems Holdings Inc',
  'SPR',
  '0001364885',
  'normal_operations',
  'Aerospace Structures Manufacturing',
  'mid_cap',
  3800000000,
  'Wichita, KS',
  3000000,
  2100000,
  45,
  '2006-09-30',
  'Jennifer Ramirez',
  'Tom Erikson, Materials Manager',
  ARRAY['Aluminum 7150 plate', 'Titanium sheet', 'Inconel fastener stock'],
  '2025-09-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-28'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'Curtiss-Wright Corporation',
  'CW',
  '0000026535',
  'normal_operations',
  'Defense & Industrial',
  'mid_cap',
  9800000000,
  'Davidson, NC',
  2500000,
  1700000,
  45,
  '2009-11-05',
  'Michael Torres',
  'Bill Nguyen, Procurement Manager',
  ARRAY['Duplex stainless plate', 'Hastelloy C-276', 'Titanium 6Al-4V'],
  '2026-11-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-02-01'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'Woodward Inc',
  'WWD',
  '0000108312',
  'normal_operations',
  'Aerospace & Industrial Controls',
  'mid_cap',
  7200000000,
  'Fort Collins, CO',
  2000000,
  1400000,
  45,
  '2011-03-20',
  'Jennifer Ramirez',
  'Eric Paulson, Supply Manager',
  ARRAY['Titanium 6Al-4V bar', 'Stainless 316L tubing', 'Inconel 625'],
  '2026-03-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-30'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'Moog Inc',
  'MOG.A',
  '0000067887',
  'normal_operations',
  'Precision Motion Control',
  'mid_cap',
  3600000000,
  'East Aurora, NY',
  1500000,
  1050000,
  45,
  '2013-05-08',
  'Jennifer Ramirez',
  'Kevin Zhao, Sourcing Lead',
  ARRAY['Titanium 6Al-4V bar', 'Inconel 718 bar', '15-5 PH stainless bar'],
  '2026-05-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-22'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'HEICO Corporation',
  'HEI',
  '0000046619',
  'normal_operations',
  'Aerospace Parts Distribution',
  'mid_cap',
  25000000000,
  'Hollywood, FL',
  2000000,
  1300000,
  45,
  '2013-09-01',
  'Jennifer Ramirez',
  'Steve Barlow, Director Procurement',
  ARRAY['Titanium alloy bar', 'Inconel 718 sheet', 'Aluminum 7075 plate'],
  '2026-09-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-05'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'Ducommun Incorporated',
  'DCO',
  '0000030305',
  'normal_operations',
  'Aerospace & Defense Manufacturing',
  'small_cap',
  1100000000,
  'Santa Ana, CA',
  1200000,
  780000,
  45,
  '2017-01-10',
  'Michael Torres',
  'Sandra Bloch, Materials Planner',
  ARRAY['Aluminum 7075 plate', 'Titanium 6Al-4V sheet', 'Stainless 17-4 PH'],
  '2026-01-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-14'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'Chart Industries Inc',
  'GTLS',
  '0000892553',
  'normal_operations',
  'Industrial Equipment / Energy',
  'mid_cap',
  5200000000,
  'Ball Ground, GA',
  1800000,
  1200000,
  45,
  '2015-02-14',
  'Jennifer Ramirez',
  'Paul Huang, Supply Chain Director',
  ARRAY['Stainless 316L plate', 'Inconel 625 tubing', 'Aluminum 5083 plate'],
  '2025-12-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-20'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'Haynes International Inc',
  'HAYN',
  '0000046080',
  'normal_operations',
  'Specialty Alloys Manufacturing',
  'small_cap',
  850000000,
  'Kokomo, IN',
  1200000,
  780000,
  30,
  '2016-07-01',
  'Michael Torres',
  'Wayne Bradford, VP Operations',
  ARRAY['Hastelloy X plate', 'Haynes 230 sheet', 'Haynes 188 foil'],
  '2026-06-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-18'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'Watts Water Technologies Inc',
  'WTS',
  '0001410172',
  'normal_operations',
  'Industrial Water Flow Control',
  'mid_cap',
  4100000000,
  'North Andover, MA',
  1500000,
  950000,
  45,
  '2014-04-22',
  'Jennifer Ramirez',
  'Rachel Hudson, Sourcing Manager',
  ARRAY['Stainless 316L pipe', 'Inconel 625 fittings', 'Duplex 2205 bar'],
  '2025-12-31',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-08'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'CIRCOR International Inc',
  'CIR',
  '0001060349',
  'normal_operations',
  'Flow & Motion Control',
  'small_cap',
  1800000000,
  'Burlington, MA',
  1000000,
  620000,
  45,
  '2018-09-15',
  'Michael Torres',
  'Tara Jameson, Materials Manager',
  ARRAY['Duplex 2205 fittings', 'Inconel 625 valves', 'Stainless 316L bar'],
  '2025-09-30',
  FALSE,
  ARRAY[]::TEXT[],
  NULL,
  '2025-01-28'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'The Nordam Group LLC',
  NULL,
  NULL,
  'normal_operations',
  'Aerospace MRO & Structures',
  'private',
  NULL,
  'Tulsa, OK',
  1500000,
  950000,
  45,
  '2015-06-01',
  'Jennifer Ramirez',
  'Ken Lackey, CFO',
  ARRAY['Titanium 6Al-4V sheet', 'Inconel 625 bar', 'Aluminum 7075 plate'],
  '2026-06-30',
  FALSE,
  ARRAY[]::TEXT[],
  'Private company. Owned by Bow River Capital PE since 2023. Annual financials required per credit policy.',
  '2025-01-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'Triumph Group Inc',
  'TGI',
  '0001021162',
  'credit_deterioration',
  'Aerospace Systems & Structures',
  'small_cap',
  680000000,
  'Berwyn, PA',
  2000000,
  1850000,
  45,
  '2009-06-15',
  'Jennifer Ramirez',
  'Mike Donaldson, CFO',
  ARRAY['Titanium 6Al-4V sheet', 'Aluminum 7075 plate', 'Stainless 17-4 PH'],
  '2025-06-30',
  FALSE,
  ARRAY['OVERDUE_60+', 'HIGH_UTILIZATION', 'WATCH_LIST', 'DUNNING_ACTIVE', 'SEC_ALERT_TRIGGERED', 'CEO_TRANSITION', 'COVENANT_WAIVER', 'STRATEGIC_REVIEW'],
  'Triumph facing multiple simultaneous risk signals: CEO departure Jan 2025, covenant waiver, pension underfunded $84M, strategic portfolio review underway. Payment pattern severely deteriorated - averaging 88-106 days vs 45-day terms. Three invoices overdue up to 69 days. SEC monitor active, alert triggered. Recommend credit limit review and COD for new orders.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'Kaman Corporation',
  'KAMN',
  '0000054381',
  'payment_issues',
  'Aerospace Distribution & Manufacturing',
  'small_cap',
  410000000,
  'Bloomfield, CT',
  1800000,
  1650000,
  45,
  '2011-03-10',
  'Jennifer Ramirez',
  'Robert Hanks, VP Finance',
  ARRAY['Aluminum 7075 plate', 'Titanium 6Al-4V bar', 'Inconel 718 bar'],
  '2025-12-31',
  FALSE,
  ARRAY['OVERDUE_30+', 'HIGH_UTILIZATION', 'WATCH_LIST', 'DUNNING_ACTIVE'],
  'Kaman completed divestiture of distribution segment. Remaining aerospace unit under cash flow pressure. Payment delays becoming systematic.',
  '2025-02-08'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'Orbital Energy Group Inc',
  'OEG',
  '0000060714',
  'payment_issues',
  'Energy Infrastructure Services',
  'small_cap',
  28000000,
  'Houston, TX',
  750000,
  680000,
  30,
  '2020-04-01',
  'Jennifer Ramirez',
  'Dennis Langford, CEO',
  ARRAY['Stainless 316L pipe', 'Duplex 2205 fittings'],
  '2024-12-31',
  FALSE,
  ARRAY['OVERDUE_60+', 'COLLECTION_REFERRAL', 'CREDIT_HOLD', 'CRITICAL_RISK'],
  'Full credit hold since 2025-01-10. November invoice escalated to collections. DO NOT SHIP without COD authorization. Contract expired — do not renew.',
  '2025-02-12'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'Global Power Equipment Group',
  'GLPW',
  '0001282266',
  'payment_issues',
  'Power Generation Equipment',
  'small_cap',
  45000000,
  'Irving, TX',
  600000,
  552000,
  45,
  '2019-08-12',
  'Michael Torres',
  'Chris Malone, CFO',
  ARRAY['Inconel 625 tubing', 'Hastelloy C-276 plate'],
  '2025-03-31',
  FALSE,
  ARRAY['OVERDUE_30+', 'HIGH_UTILIZATION', 'DUNNING_ACTIVE', 'WATCH_LIST'],
  'Customer facing severe competitive pressure from overseas manufacturers. Contract renewal under review. Do not increase limit.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'Vertex Energy Inc',
  'VTNR',
  '0001396033',
  'payment_issues',
  'Refined Petroleum Products',
  'small_cap',
  120000000,
  'Houston, TX',
  500000,
  445000,
  30,
  '2021-06-01',
  'Michael Torres',
  'Ben Cowart, CEO',
  ARRAY['Stainless 316L plate', 'Duplex 2205 pipe'],
  '2025-06-30',
  FALSE,
  ARRAY['OVERDUE_30+', 'HIGH_UTILIZATION', 'DUNNING_ACTIVE'],
  'Vertex completed acquisition of Mobile refinery with heavy debt load. Experiencing margin compression. Monitor closely.',
  '2025-02-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'ProPetro Holding Corp',
  'PUMP',
  '0001681903',
  'payment_issues',
  'Oilfield Services',
  'small_cap',
  550000000,
  'Midland, TX',
  800000,
  710000,
  45,
  '2020-10-15',
  'Michael Torres',
  'Sam Sledge, CEO',
  ARRAY['Duplex 2205 tubing', 'Inconel 625 valve components'],
  '2025-09-30',
  FALSE,
  ARRAY['OVERDUE_30+', 'DUNNING_ACTIVE', 'WATCH_LIST'],
  'Payment delays correlate with oil price volatility. Monitor closely through Q2.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'Ranger Energy Services Inc',
  'RNGR',
  '0001679363',
  'payment_issues',
  'Oil & Gas Field Services',
  'small_cap',
  140000000,
  'Houston, TX',
  400000,
  375000,
  30,
  '2022-03-01',
  'Jennifer Ramirez',
  'Stuart Bodden, CFO',
  ARRAY['Stainless 316L pipe fittings', 'Carbon steel pipe'],
  '2025-03-31',
  FALSE,
  ARRAY['OVERDUE_30+', 'HIGH_UTILIZATION', 'DUNNING_ACTIVE', 'WATCH_LIST'],
  'Smaller oilfield service firm with tight working capital. Contract expiry approaching — renewal uncertain.',
  '2025-02-14'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'Nordam Group - Legacy Division',
  NULL,
  NULL,
  'payment_issues',
  'Aerospace Repair & Overhaul',
  'private',
  NULL,
  'Tulsa, OK',
  500000,
  510000,
  45,
  '2020-09-01',
  'Jennifer Ramirez',
  'Diane Shelley, AP Manager',
  ARRAY['Titanium 6Al-4V plate', 'Aluminum 6061 plate'],
  '2025-04-30',
  FALSE,
  ARRAY['OVERDUE_30+', 'HIGH_UTILIZATION', 'DUNNING_ACTIVE', 'WATCH_LIST'],
  'Legacy MRO division under new PE ownership (Bow River Capital). Parent guarantee requested, not yet received. Separate account from normal ops Nordam account.',
  '2025-02-12'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'Arconic Corporation',
  'ARNC',
  '0001790420',
  'credit_deterioration',
  'Aluminum & Specialty Metals',
  'mid_cap',
  1800000000,
  'Pittsburgh, PA',
  3000000,
  2750000,
  45,
  '2012-04-01',
  'Jennifer Ramirez',
  'William Oplinger, CFO',
  ARRAY['Titanium 6Al-4V plate', 'Inconel 718 sheet', 'Stainless 316L'],
  '2025-06-30',
  FALSE,
  ARRAY['CREDIT_DETERIORATION', 'RATING_DOWNGRADE', 'COVENANT_WAIVER', 'WATCH_LIST'],
  'Moody''s downgrade Jan 2025 to B1 from Ba3. Covenant waiver obtained Q4 2024. Recommend reducing credit limit to $2M.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'McDermott International Ltd',
  'MDR',
  '0000854422',
  'credit_deterioration',
  'Engineering & Construction',
  'small_cap',
  380000000,
  'Houston, TX',
  1500000,
  1380000,
  45,
  '2016-08-01',
  'Michael Torres',
  'Samik Mukherjee, CFO',
  ARRAY['Duplex 2205 plate', 'Inconel 625 tubing', 'Hastelloy C-276'],
  '2025-04-30',
  FALSE,
  ARRAY['CREDIT_DETERIORATION', 'RATING_DOWNGRADE', 'RESTRUCTURING_RISK', 'COLLECTION_RISK', 'CRITICAL_RISK'],
  'URGENT: MDR engaged restructuring advisors Jan 22 2025 (Lazard + Kirkland). Prior Ch.11 in 2019. Recommend limit reduction to $500K and COD for new orders. Escalate to CFO.',
  '2025-02-05'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'Superior Industries International Inc',
  'SUP',
  '0000095552',
  'credit_deterioration',
  'Aluminum Wheels Manufacturing',
  'small_cap',
  95000000,
  'Southfield, MI',
  800000,
  720000,
  45,
  '2018-05-15',
  'Jennifer Ramirez',
  'Timothy Trenary, CFO',
  ARRAY['Aluminum 6061 plate', 'Aluminum 5083 sheet'],
  '2025-05-31',
  FALSE,
  ARRAY['CREDIT_DETERIORATION', 'EARNINGS_MISS', 'WATCH_LIST'],
  'Auto sector headwinds. Dividend suspended Feb 2025. Q4 missed by 31%. Recommend credit limit review.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'Coeur Mining Inc',
  'CDE',
  '0000215243',
  'credit_deterioration',
  'Silver & Gold Mining',
  'small_cap',
  2800000000,
  'Chicago, IL',
  1000000,
  890000,
  45,
  '2019-09-01',
  'Michael Torres',
  'Thomas Whelan, SVP Finance',
  ARRAY['Hastelloy C-276 mining equipment parts', 'Duplex 2205 processing pipe'],
  '2025-12-31',
  FALSE,
  ARRAY['CREDIT_DETERIORATION', 'OUTLOOK_NEGATIVE', 'ACQUISITION_RISK'],
  'CDE integrating large SilverCrest acquisition. Balance sheet stretched. Silver price headwind. Fitch negative outlook.',
  '2025-02-01'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'Mistras Group Inc',
  'MG',
  '0001436523',
  'credit_deterioration',
  'NDT & Infrastructure Testing',
  'small_cap',
  280000000,
  'Princeton Junction, NJ',
  600000,
  545000,
  45,
  '2020-07-01',
  'Jennifer Ramirez',
  'Jonathan Wolk, Interim CFO',
  ARRAY['Stainless pipe fittings', 'Alloy testing samples'],
  '2025-06-30',
  FALSE,
  ARRAY['CREDIT_DETERIORATION', 'MANAGEMENT_CHANGE', 'GOODWILL_IMPAIRMENT'],
  'CFO departure January 2025 concerning. $42M goodwill impairment Q3 2024. Cash flow under pressure. Monitor closely.',
  '2025-01-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'General Electric Company (Power segment)',
  'GE',
  '0000040534',
  'credit_deterioration',
  'Power Generation',
  'large_cap',
  160000000000,
  'Boston, MA',
  2500000,
  2200000,
  60,
  '2011-05-01',
  'Sarah Chen',
  'Paul Cates, SVP Supply Chain',
  ARRAY['Inconel 718 turbine disk forgings', 'Rene 41 bar', 'Waspaloy sheet'],
  '2025-10-31',
  FALSE,
  ARRAY['PAYMENT_SLOWDOWN', 'WATCH_LIST'],
  'GE Power segment payments have slowed since GE spin-off into GEV/GEHC. Need to confirm which entity is now responsible for POs. Payment terms moved from 45 to 60 days unilaterally.',
  '2025-02-08'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'Spirit Airlines Inc',
  'SAVE',
  '0001289419',
  'negative_news',
  'Ultra-Low-Cost Air Travel',
  'small_cap',
  180000000,
  'Miramar, FL',
  1200000,
  1080000,
  45,
  '2017-04-01',
  'Jennifer Ramirez',
  'Fred Cromer, CFO',
  ARRAY['Aluminum 7075 aircraft parts', 'Titanium fittings', 'Stainless 316L tube'],
  '2025-04-30',
  FALSE,
  ARRAY['BANKRUPTCY_RISK', 'CRITICAL_RISK', 'CREDIT_HOLD', 'WATCH_LIST'],
  'CRITICAL: Spirit Airlines filed Chapter 11 November 18 2024, Case 23-11993 NJ. All open invoices now pre-petition claims. Do not ship. File proof of claim by March 31 2025.',
  '2025-02-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'AECOM Technology Corporation',
  'ACM',
  '0000868857',
  'negative_news',
  'Engineering & Construction Services',
  'large_cap',
  12000000000,
  'Dallas, TX',
  2000000,
  1650000,
  45,
  '2013-08-01',
  'Michael Torres',
  'Gaurav Kapoor, CFO',
  ARRAY['Stainless 316L construction pipe', 'Duplex 2205 fittings', 'Inconel valves'],
  '2026-08-31',
  FALSE,
  ARRAY['SEC_INVESTIGATION', 'NEWS_MONITORING_INCREASED', 'WATCH_LIST'],
  'SEC investigation on revenue recognition announced Jan 2025. 10-K filing delayed. Monitor closely. Do not increase limits pending resolution.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'Liqtech International AS',
  'LIQT',
  '0001307950',
  'negative_news',
  'Industrial Filtration Technology',
  'small_cap',
  45000000,
  'Hobro, Denmark',
  400000,
  365000,
  45,
  '2019-01-15',
  'Jennifer Ramirez',
  'Roger Gimbel, CFO',
  ARRAY['Stainless 316L tubing', 'Hastelloy C-276 filter housings'],
  '2025-01-31',
  FALSE,
  ARRAY['CONTRACT_LOSS', 'REVENUE_DECLINE', 'CREDIT_DETERIORATION', 'WATCH_LIST'],
  'Liqtech lost Navy contract (30% of revenue) Q4 2024. 45% revenue decline year-over-year. 25% workforce reduction announced. Contract expired — do not renew.',
  '2025-02-12'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'American Airlines Group Inc',
  'AAL',
  '0000004515',
  'negative_news',
  'Commercial Aviation',
  'mid_cap',
  7800000000,
  'Fort Worth, TX',
  3000000,
  2400000,
  45,
  '2009-06-15',
  'Sarah Chen',
  'Devon May, VP Procurement',
  ARRAY['Aluminum 7075 aircraft structural parts', 'Titanium 6Al-4V bar', 'Stainless 316L tubing'],
  '2027-06-30',
  FALSE,
  ARRAY['GUIDANCE_CUT', 'NEWS_MONITORING_INCREASED'],
  'Q1 2025 guidance cut 3.5% on lower demand. DOJ reviewing alliance with JetBlue (appeal pending). Monitor but no limit change needed currently.',
  '2025-02-14'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'Maxar Technologies Inc',
  'MAXR',
  '0001802665',
  'negative_news',
  'Earth Intelligence & Space Infrastructure',
  'mid_cap',
  5800000000,
  'Westminster, CO',
  1500000,
  1250000,
  45,
  '2018-11-01',
  'Michael Torres',
  'Biggs Porter, CFO',
  ARRAY['Titanium 6Al-4V satellite structural members', 'Invar 36 precision parts', 'Aluminum 7075'],
  '2026-10-31',
  FALSE,
  ARRAY['TECHNICAL_INCIDENT', 'NEWS_MONITORING_INCREASED', 'WATCH_LIST'],
  'WorldView-3 satellite anomaly March 2024 reduced imagery capacity by 40%. Insurance claim filed. Revenue impact significant. Monitor.',
  '2025-02-12'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'Rite Aid Corporation',
  'RAD',
  '0000084129',
  'bankruptcy',
  'Retail Pharmacy',
  'small_cap',
  0,
  'Philadelphia, PA',
  500000,
  487000,
  45,
  '2015-03-01',
  'Jennifer Ramirez',
  'Jeffrey Stein, CRO',
  ARRAY['Stainless 316L HVAC pipe', 'Aluminum 6061 structural'],
  NULL,
  FALSE,
  ARRAY['BANKRUPTCY', 'COLLECTIONS', 'CREDIT_HOLD', 'PROOF_OF_CLAIM_FILED'],
  'Rite Aid Ch.11 filed 10/15/2023, Case 23-18993 NJ. Plan confirmed 8/29/2024. Proof of claim filed $487K. Estimated recovery 28% (~$136K). Monitor for distribution.',
  '2025-02-01'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'Yellow Corporation',
  'YELLQ',
  '0000700923',
  'bankruptcy',
  'Less-Than-Truckload Freight',
  'small_cap',
  0,
  'Nashville, TN',
  600000,
  298000,
  45,
  '2016-02-01',
  'Michael Torres',
  'Darren Hawkins, CEO (pre-BK)',
  ARRAY['Steel pipe', 'Aluminum structural sections'],
  NULL,
  FALSE,
  ARRAY['BANKRUPTCY', 'CHAPTER_7', 'COLLECTIONS', 'CREDIT_HOLD', 'PROOF_OF_CLAIM_FILED'],
  'Yellow Ch.11 filed 8/6/2023, Case 23-11069 DE. Converted to Ch.7 3/15/2024. Trustee: Edmond George. Claim $298K, est. recovery 5% (~$15K). Asset liquidation ongoing.',
  '2025-01-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'Proterra Inc',
  'PTRA',
  '0001816810',
  'bankruptcy',
  'Electric Transit Vehicles',
  'small_cap',
  0,
  'Burlingame, CA',
  500000,
  378000,
  45,
  '2021-05-01',
  'Jennifer Ramirez',
  'Gareth Joyce, CEO (pre-BK)',
  ARRAY['Aluminum 6061 bus structural', 'Stainless 316L fittings'],
  NULL,
  FALSE,
  ARRAY['BANKRUPTCY', 'ASSETS_SOLD', 'CREDIT_HOLD', 'PROOF_OF_CLAIM_FILED'],
  'Proterra Ch.11 filed 8/7/2023, Case 23-11120 DE. 363 sale complete: Transit bus biz sold to NFI Group, Powered by Proterra to Volvo. Claim $378K, est. recovery 12% (~$45K).',
  '2025-01-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'Joby Aviation Inc',
  'JOBY',
  '0001724570',
  'growth_opportunity',
  'Electric Air Taxi (eVTOL)',
  'mid_cap',
  6800000000,
  'Santa Cruz, CA',
  500000,
  280000,
  45,
  '2022-06-01',
  'Jennifer Ramirez',
  'Matt Field, CFO',
  ARRAY['Titanium 6Al-4V precision machined parts', 'Inconel 718 fastener stock'],
  '2025-12-31',
  FALSE,
  ARRAY['GROWTH_OPPORTUNITY', 'PREFERRED_SUPPLIER_CANDIDATE'],
  'Joby received FAA Part 135 certification. Toyota $400M investment Q4 2024. Dubai air taxi MOU signed. Recommend credit limit increase to $2M.',
  '2025-02-08'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'Archer Aviation Inc',
  'ACHR',
  '0001779128',
  'growth_opportunity',
  'Electric Air Taxi (eVTOL)',
  'small_cap',
  3200000000,
  'San Jose, CA',
  400000,
  220000,
  45,
  '2022-09-01',
  'Jennifer Ramirez',
  'Mark Mesler, CFO',
  ARRAY['Titanium 6Al-4V sheet', 'Aluminum 7075 structural'],
  '2025-09-30',
  FALSE,
  ARRAY['GROWTH_OPPORTUNITY'],
  'United Airlines 100-aircraft order confirmed. DOD Urban Air Mobility contract won. Recommend limit increase to $1.5M.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'GE Vernova Inc',
  'GEV',
  '0002013928',
  'growth_opportunity',
  'Power Generation & Grid Solutions',
  'large_cap',
  78000000000,
  'Cambridge, MA',
  3000000,
  2200000,
  45,
  '2024-04-02',
  'Sarah Chen',
  'Kenneth Parks, CFO',
  ARRAY['Inconel 718 turbine components', 'Hastelloy X plate', 'Nickel superalloy bar'],
  '2026-12-31',
  TRUE,
  ARRAY['GROWTH_OPPORTUNITY', 'PREFERRED_SUPPLIER_CANDIDATE'],
  'GEV spun out from GE April 2024. $116B backlog. Data center power partnerships driving massive demand. Recommend limit increase to $6M.',
  '2025-02-05'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'Leonardo DRS Inc',
  'DRS',
  '0001675644',
  'growth_opportunity',
  'Defense Electronics',
  'mid_cap',
  8500000000,
  'Arlington, VA',
  2000000,
  1600000,
  45,
  '2019-07-01',
  'Sarah Chen',
  'Mike Dippold, CFO',
  ARRAY['Titanium 6Al-4V electronic enclosures', 'Aluminum 7075 chassis', 'Invar 36'],
  '2026-07-31',
  TRUE,
  ARRAY['GROWTH_OPPORTUNITY'],
  '$2.8B SHORAD contract win Feb 2025. Consistent premium payment performer. Recommend limit increase to $4M.',
  '2025-02-10'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'Bloom Energy Corporation',
  'BE',
  '0001664703',
  'growth_opportunity',
  'Clean Energy / Fuel Cells',
  'small_cap',
  2400000000,
  'San Jose, CA',
  1500000,
  980000,
  45,
  '2020-10-01',
  'Michael Torres',
  'Greg Cameron, CFO',
  ARRAY['Inconel 625 fuel cell components', 'Stainless 316L manifolds', 'Hastelloy C-276 fittings'],
  '2026-10-31',
  FALSE,
  ARRAY['GROWTH_OPPORTUNITY'],
  'Microsoft 1GW fuel cell agreement is transformational. Data center demand driving orders. Recommend limit increase to $2.5M.',
  '2025-02-01'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'Textron Inc',
  'TXT',
  '0000217346',
  'sec_filing_monitoring',
  'Aerospace, Defense & Industrial',
  'large_cap',
  16000000000,
  'Providence, RI',
  4000000,
  2800000,
  45,
  '2008-09-15',
  'Sarah Chen',
  'Frank Connor, CFO',
  ARRAY['Titanium 6Al-4V Bell helicopter components', 'Inconel 718 turbine parts', 'Aluminum 7075 plate'],
  '2027-09-30',
  TRUE,
  ARRAY[]::TEXT[],
  'Clean 10-K filing reviewed Feb 2025. No issues detected. SEC monitoring active per standard protocol for large accounts.',
  '2025-02-15'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO customers (
  id, company_name, ticker, sec_cik, scenario, industry,
  market_cap_tier, market_cap_usd, headquarters,
  credit_limit, current_exposure, payment_terms_days,
  customer_since, account_manager, primary_contact,
  primary_products, contract_expiry, preferred_customer,
  flags, notes, last_reviewed
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'Heliogen Inc',
  'HLGN',
  '0001848948',
  'sec_filing_monitoring',
  'Concentrated Solar Power',
  'small_cap',
  85000000,
  'Pasadena, CA',
  600000,
  420000,
  30,
  '2021-08-01',
  'Jennifer Ramirez',
  'Chris Homek, CEO',
  ARRAY['Hastelloy C-276 heat exchanger tubing', 'Inconel 625 receiver parts', 'Stainless 316L fittings'],
  '2025-08-31',
  FALSE,
  ARRAY['GOING_CONCERN', 'SEC_ALERT_TRIGGERED', 'WATCH_LIST', 'CREDIT_LIMIT_REDUCTION'],
  'ALERT: 10-Q filed Jan 12 2025 contains going concern warning. Only 2.5 quarters of cash runway. Credit limit reduced from $600K to $400K on Feb 5. Do not increase exposure.',
  '2025-02-05'
) ON CONFLICT (id) DO NOTHING;

-- INVOICES
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0891',
  2100000,
  0,
  '2025-01-01',
  '2025-02-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  'Titanium 6Al-4V plate PO#BA-78234'
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0934',
  1800000,
  0,
  '2025-01-15',
  '2025-03-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  'Inconel 718 bar stock PO#BA-78401'
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0978',
  1300000,
  0,
  '2025-02-01',
  '2025-03-20',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  'Titanium 3Al-2.5V tubing PO#BA-78512'
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0541',
  2300000,
  0,
  '2025-01-06',
  '2025-02-20',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0612',
  1500000,
  0,
  '2025-01-25',
  '2025-03-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0688',
  1000000,
  0,
  '2025-02-08',
  '2025-03-25',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0788',
  2100000,
  0,
  '2025-01-11',
  '2025-02-25',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0812',
  1200000,
  0,
  '2025-02-01',
  '2025-03-18',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0856',
  800000,
  0,
  '2025-02-18',
  '2025-04-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0678',
  1300000,
  0,
  '2025-01-26',
  '2025-03-12',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0712',
  900000,
  0,
  '2025-02-18',
  '2025-04-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0891',
  2200000,
  0,
  '2025-01-08',
  '2025-02-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0934',
  1100000,
  0,
  '2025-01-29',
  '2025-03-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0967',
  500000,
  0,
  '2025-02-15',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0512',
  1600000,
  0,
  '2025-01-16',
  '2025-03-02',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0556',
  1200000,
  0,
  '2025-02-08',
  '2025-03-25',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0445',
  1500000,
  0,
  '2025-01-14',
  '2025-02-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0489',
  700000,
  0,
  '2025-02-05',
  '2025-03-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0512',
  400000,
  0,
  '2025-02-28',
  '2025-04-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0345',
  1800000,
  0,
  '2025-01-15',
  '2025-03-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0389',
  900000,
  0,
  '2025-02-05',
  '2025-03-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0412',
  500000,
  0,
  '2025-02-24',
  '2025-04-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0567',
  1400000,
  0,
  '2025-01-19',
  '2025-03-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0598',
  1000000,
  0,
  '2025-02-11',
  '2025-03-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2024-0234',
  1200000,
  0,
  '2025-01-24',
  '2025-03-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2024-0278',
  900000,
  0,
  '2025-02-15',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'INV-CW-2024-0321',
  1000000,
  0,
  '2025-01-22',
  '2025-03-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'INV-CW-2024-0356',
  700000,
  0,
  '2025-02-15',
  '2025-04-02',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'INV-WWD-2024-0456',
  900000,
  0,
  '2025-01-19',
  '2025-03-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'INV-WWD-2024-0489',
  500000,
  0,
  '2025-02-11',
  '2025-03-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'INV-MOG-2024-0289',
  650000,
  0,
  '2025-01-24',
  '2025-03-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'INV-MOG-2024-0312',
  400000,
  0,
  '2025-02-17',
  '2025-04-03',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'INV-HEI-2024-0234',
  800000,
  0,
  '2025-02-01',
  '2025-03-18',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'INV-HEI-2024-0267',
  500000,
  0,
  '2025-02-24',
  '2025-04-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'INV-DCO-2024-0156',
  480000,
  0,
  '2025-01-29',
  '2025-03-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'INV-DCO-2024-0189',
  300000,
  0,
  '2025-02-22',
  '2025-04-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'INV-GTLS-2024-0234',
  750000,
  0,
  '2025-01-22',
  '2025-03-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'INV-GTLS-2024-0267',
  450000,
  0,
  '2025-02-15',
  '2025-04-02',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'INV-HAYN-2024-0123',
  500000,
  0,
  '2025-02-18',
  '2025-03-20',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'INV-HAYN-2024-0145',
  280000,
  0,
  '2025-03-13',
  '2025-04-12',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'INV-WTS-2024-0189',
  600000,
  0,
  '2025-01-28',
  '2025-03-14',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'INV-WTS-2024-0212',
  350000,
  0,
  '2025-02-21',
  '2025-04-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'INV-CIR-2024-0178',
  380000,
  0,
  '2025-02-08',
  '2025-03-25',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'INV-CIR-2024-0201',
  240000,
  0,
  '2025-03-04',
  '2025-04-18',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'INV-NRDM-2024-0234',
  580000,
  0,
  '2025-01-21',
  '2025-03-07',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'INV-NRDM-2024-0267',
  370000,
  0,
  '2025-02-14',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0445',
  650000,
  0,
  '2024-11-01',
  '2024-12-15',
  69,
  'overdue',
  '3',
  '2025-01-20',
  '2025-02-20',
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0489',
  580000,
  0,
  '2024-11-21',
  '2025-01-05',
  48,
  'overdue',
  '2',
  '2025-01-28',
  '2025-02-15',
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0523',
  420000,
  0,
  '2024-12-06',
  '2025-01-20',
  33,
  'overdue',
  '1',
  '2025-02-05',
  '2025-02-22',
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2025-0012',
  200000,
  0,
  '2025-01-14',
  '2025-02-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2025-0023',
  520000,
  0,
  '2024-12-20',
  '2025-02-03',
  19,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2025-0028',
  330000,
  0,
  '2025-01-14',
  '2025-02-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0378',
  720000,
  0,
  '2024-11-03',
  '2024-12-28',
  56,
  'overdue',
  '2',
  '2025-01-25',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0412',
  530000,
  0,
  '2024-12-04',
  '2025-01-18',
  35,
  'overdue',
  '1',
  '2025-02-08',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2025-0025',
  400000,
  0,
  '2025-01-24',
  '2025-03-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2024-0189',
  310000,
  0,
  '2024-11-01',
  '2024-11-30',
  84,
  'overdue',
  '4',
  '2025-01-10',
  NULL,
  TRUE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2024-0223',
  245000,
  0,
  '2024-11-21',
  '2024-12-20',
  64,
  'overdue',
  '3',
  '2025-01-28',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2025-0005',
  125000,
  0,
  '2025-01-16',
  '2025-02-15',
  7,
  'overdue',
  '1',
  '2025-02-18',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2024-0267',
  280000,
  0,
  '2024-11-21',
  '2025-01-05',
  48,
  'overdue',
  '2',
  '2025-01-28',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2024-0298',
  185000,
  0,
  '2024-12-11',
  '2025-01-25',
  28,
  'overdue',
  '1',
  '2025-02-10',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2025-0008',
  87000,
  0,
  '2025-01-17',
  '2025-03-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0312',
  225000,
  0,
  '2024-12-11',
  '2025-01-10',
  43,
  'overdue',
  '2',
  '2025-01-30',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2025-0009',
  135000,
  0,
  '2025-01-11',
  '2025-02-10',
  12,
  'overdue',
  '1',
  '2025-02-16',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2025-0018',
  85000,
  0,
  '2025-02-03',
  '2025-03-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2024-0401',
  380000,
  0,
  '2024-12-01',
  '2025-01-15',
  38,
  'overdue',
  '1',
  '2025-02-05',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2025-0011',
  330000,
  0,
  '2025-01-15',
  '2025-03-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2024-0289',
  175000,
  0,
  '2024-12-09',
  '2024-12-31',
  53,
  'overdue',
  '2',
  '2025-01-28',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2025-0003',
  125000,
  0,
  '2025-01-12',
  '2025-02-01',
  21,
  'overdue',
  '1',
  '2025-02-14',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2025-0018',
  75000,
  0,
  '2025-02-13',
  '2025-03-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2024-0189',
  215000,
  0,
  '2024-12-01',
  '2025-01-15',
  38,
  'overdue',
  '1',
  '2025-02-05',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2024-0212',
  185000,
  0,
  '2024-12-22',
  '2025-02-05',
  17,
  'overdue',
  '1',
  '2025-02-15',
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2025-0004',
  110000,
  0,
  '2025-01-25',
  '2025-03-11',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0512',
  1200000,
  0,
  '2024-12-27',
  '2025-02-10',
  12,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0556',
  980000,
  0,
  '2025-01-15',
  '2025-03-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2025-0005',
  570000,
  0,
  '2025-02-05',
  '2025-03-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0445',
  680000,
  0,
  '2024-12-06',
  '2025-01-20',
  33,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0489',
  450000,
  0,
  '2024-12-29',
  '2025-02-12',
  10,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2025-0004',
  250000,
  0,
  '2025-01-29',
  '2025-03-15',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2024-0334',
  380000,
  0,
  '2025-01-14',
  '2025-01-28',
  25,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2025-0003',
  220000,
  0,
  '2025-01-19',
  '2025-03-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2025-0009',
  120000,
  0,
  '2025-02-15',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2024-0278',
  420000,
  0,
  '2024-12-22',
  '2025-02-05',
  17,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2025-0006',
  280000,
  0,
  '2025-01-24',
  '2025-03-10',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2025-0012',
  190000,
  0,
  '2025-02-18',
  '2025-04-05',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2024-0201',
  290000,
  0,
  '2025-01-08',
  '2025-01-22',
  31,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2025-0004',
  165000,
  0,
  '2025-01-22',
  '2025-03-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2025-0010',
  90000,
  0,
  '2025-02-16',
  '2025-04-02',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0556',
  1100000,
  0,
  '2025-01-11',
  '2025-03-12',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0589',
  700000,
  0,
  '2025-02-01',
  '2025-04-02',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2025-0002',
  400000,
  0,
  '2025-02-20',
  '2025-04-21',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0334',
  580000,
  0,
  '2024-10-15',
  '2024-11-29',
  85,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0378',
  310000,
  0,
  '2024-10-31',
  '2024-12-15',
  69,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0412',
  190000,
  0,
  '2024-11-10',
  '2024-12-25',
  59,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0689',
  900000,
  0,
  '2025-01-05',
  '2025-02-19',
  3,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0712',
  510000,
  0,
  '2025-01-22',
  '2025-03-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2025-0003',
  240000,
  0,
  '2025-02-14',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2024-0178',
  225000,
  0,
  '2024-12-01',
  '2025-01-15',
  38,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2025-0002',
  140000,
  0,
  '2025-01-14',
  '2025-02-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0778',
  1400000,
  0,
  '2025-01-08',
  '2025-02-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0812',
  600000,
  0,
  '2025-01-28',
  '2025-03-14',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2025-0005',
  400000,
  0,
  '2025-02-20',
  '2025-04-06',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0556',
  750000,
  0,
  '2025-01-12',
  '2025-02-26',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0589',
  500000,
  0,
  '2025-02-04',
  '2025-03-21',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0334',
  220000,
  0,
  '2023-09-01',
  '2023-10-15',
  495,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0356',
  175000,
  0,
  '2023-09-22',
  '2023-11-06',
  473,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0378',
  92000,
  0,
  '2023-10-08',
  '2023-11-22',
  457,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'INV-YELLQ-2023-0189',
  175000,
  0,
  '2023-07-01',
  '2023-08-15',
  556,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'INV-YELLQ-2023-0212',
  123000,
  0,
  '2023-07-22',
  '2023-09-05',
  535,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'INV-PTRA-2023-0201',
  210000,
  0,
  '2023-06-15',
  '2023-07-30',
  573,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'INV-PTRA-2023-0223',
  168000,
  0,
  '2023-07-10',
  '2023-08-24',
  547,
  'pre_petition',
  NULL,
  NULL,
  NULL,
  FALSE,
  TRUE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2024-0145',
  180000,
  0,
  '2025-01-22',
  '2025-03-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2025-0002',
  100000,
  0,
  '2025-02-15',
  '2025-04-01',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'INV-ACHR-2024-0123',
  145000,
  0,
  '2025-01-28',
  '2025-03-14',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'INV-ACHR-2025-0002',
  75000,
  0,
  '2025-02-20',
  '2025-04-06',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0289',
  1300000,
  0,
  '2025-01-10',
  '2025-02-24',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0312',
  900000,
  0,
  '2025-02-01',
  '2025-03-18',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0489',
  950000,
  0,
  '2025-01-18',
  '2025-03-04',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0512',
  650000,
  0,
  '2025-02-10',
  '2025-03-27',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0289',
  580000,
  0,
  '2025-01-20',
  '2025-03-06',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2025-0002',
  400000,
  0,
  '2025-02-12',
  '2025-03-29',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0678',
  1600000,
  0,
  '2025-01-14',
  '2025-02-28',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0712',
  780000,
  0,
  '2025-02-05',
  '2025-03-22',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2025-0002',
  420000,
  0,
  '2025-02-22',
  '2025-04-08',
  0,
  'current',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2024-0201',
  250000,
  0,
  '2024-12-15',
  '2025-01-14',
  39,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;
INSERT INTO invoices (
  customer_id, invoice_number, invoice_amount, amount_paid,
  invoice_date, due_date, days_overdue, status,
  dunning_stage, dunning_sent_date, next_dunning_date,
  escalated_to_collections, claimable, product_description
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2025-0003',
  170000,
  0,
  '2025-01-18',
  '2025-02-17',
  5,
  'overdue',
  NULL,
  NULL,
  NULL,
  FALSE,
  FALSE,
  NULL
) ON CONFLICT (invoice_number) DO NOTHING;

-- PAYMENT TRANSACTIONS
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0812',
  '2024-12-14',
  2400000,
  'wire_transfer',
  '2024-10-30',
  '2024-12-14',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0756',
  '2024-11-12',
  1900000,
  'wire_transfer',
  '2024-09-28',
  '2024-11-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0701',
  '2024-10-08',
  2200000,
  'wire_transfer',
  '2024-08-24',
  '2024-10-08',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0645',
  '2024-09-05',
  1750000,
  'wire_transfer',
  '2024-07-22',
  '2024-09-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0589',
  '2024-08-02',
  2100000,
  'wire_transfer',
  '2024-06-18',
  '2024-08-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0534',
  '2024-07-01',
  1600000,
  'wire_transfer',
  '2024-05-17',
  '2024-07-01',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0478',
  '2024-06-03',
  2350000,
  'wire_transfer',
  '2024-04-19',
  '2024-06-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0412',
  '2024-05-02',
  1980000,
  'wire_transfer',
  '2024-03-18',
  '2024-05-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0356',
  '2024-03-29',
  2100000,
  'wire_transfer',
  '2024-02-13',
  '2024-03-29',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2024-0301',
  '2024-02-26',
  1850000,
  'wire_transfer',
  '2024-01-12',
  '2024-02-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2023-1289',
  '2024-01-23',
  2200000,
  'wire_transfer',
  '2023-12-09',
  '2024-01-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  'INV-BA-2023-1234',
  '2023-12-19',
  1750000,
  'wire_transfer',
  '2023-11-04',
  '2023-12-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0489',
  '2025-01-05',
  2100000,
  'wire_transfer',
  '2024-11-21',
  '2025-01-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0412',
  '2024-11-22',
  1800000,
  'wire_transfer',
  '2024-10-08',
  '2024-11-22',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0356',
  '2024-10-15',
  2400000,
  'wire_transfer',
  '2024-08-31',
  '2024-10-15',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0301',
  '2024-09-12',
  1950000,
  'wire_transfer',
  '2024-07-29',
  '2024-09-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0245',
  '2024-08-09',
  2200000,
  'wire_transfer',
  '2024-06-25',
  '2024-08-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0189',
  '2024-07-06',
  1700000,
  'wire_transfer',
  '2024-05-22',
  '2024-07-06',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0134',
  '2024-06-03',
  2050000,
  'wire_transfer',
  '2024-04-19',
  '2024-06-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  'INV-RTX-2024-0078',
  '2024-05-01',
  1900000,
  'wire_transfer',
  '2024-03-17',
  '2024-05-01',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0712',
  '2025-01-08',
  2300000,
  'wire_transfer',
  '2024-11-24',
  '2025-01-08',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0645',
  '2024-11-25',
  1850000,
  'wire_transfer',
  '2024-10-11',
  '2024-11-25',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0578',
  '2024-10-18',
  2050000,
  'wire_transfer',
  '2024-09-03',
  '2024-10-18',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0512',
  '2024-09-15',
  1900000,
  'wire_transfer',
  '2024-08-01',
  '2024-09-15',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0445',
  '2024-08-12',
  2200000,
  'wire_transfer',
  '2024-06-28',
  '2024-08-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  'INV-LMT-2024-0378',
  '2024-07-09',
  1650000,
  'wire_transfer',
  '2024-05-25',
  '2024-07-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0612',
  '2025-01-22',
  1450000,
  'wire_transfer',
  '2024-12-08',
  '2025-01-22',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0545',
  '2024-12-09',
  1200000,
  'wire_transfer',
  '2024-10-25',
  '2024-12-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0478',
  '2024-10-26',
  1650000,
  'wire_transfer',
  '2024-09-11',
  '2024-10-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0412',
  '2024-09-23',
  1100000,
  'wire_transfer',
  '2024-08-09',
  '2024-09-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0345',
  '2024-08-20',
  1350000,
  'wire_transfer',
  '2024-07-06',
  '2024-08-20',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  'INV-PH-2024-0278',
  '2024-07-17',
  1200000,
  'wire_transfer',
  '2024-06-02',
  '2024-07-17',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0812',
  '2025-01-05',
  2400000,
  'wire_transfer',
  '2024-11-21',
  '2025-01-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0745',
  '2024-11-22',
  1850000,
  'wire_transfer',
  '2024-10-08',
  '2024-11-22',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0678',
  '2024-10-15',
  2050000,
  'wire_transfer',
  '2024-08-31',
  '2024-10-15',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0612',
  '2024-09-10',
  1700000,
  'wire_transfer',
  '2024-07-27',
  '2024-09-10',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0545',
  '2024-08-07',
  2200000,
  'wire_transfer',
  '2024-06-23',
  '2024-08-07',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  'INV-PCC-2024-0478',
  '2024-07-04',
  1950000,
  'wire_transfer',
  '2024-05-20',
  '2024-07-04',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0445',
  '2025-01-13',
  1800000,
  'wire_transfer',
  '2024-11-29',
  '2025-01-13',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0378',
  '2024-11-30',
  1500000,
  'wire_transfer',
  '2024-10-16',
  '2024-11-30',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0312',
  '2024-10-27',
  2100000,
  'wire_transfer',
  '2024-09-12',
  '2024-10-27',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0245',
  '2024-09-23',
  1650000,
  'wire_transfer',
  '2024-08-09',
  '2024-09-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  'INV-BKR-2024-0178',
  '2024-08-20',
  1900000,
  'wire_transfer',
  '2024-07-06',
  '2024-08-20',
  47,
  -2,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0389',
  '2025-01-11',
  1900000,
  'wire_transfer',
  '2024-11-27',
  '2025-01-11',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0312',
  '2024-11-28',
  1450000,
  'wire_transfer',
  '2024-10-14',
  '2024-11-28',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0234',
  '2024-10-21',
  1700000,
  'wire_transfer',
  '2024-09-06',
  '2024-10-21',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0156',
  '2024-09-18',
  1200000,
  'wire_transfer',
  '2024-08-04',
  '2024-09-18',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  'INV-HII-2024-0078',
  '2024-08-15',
  1600000,
  'wire_transfer',
  '2024-07-01',
  '2024-08-15',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0289',
  '2025-01-12',
  2000000,
  'wire_transfer',
  '2024-11-28',
  '2025-01-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0234',
  '2024-11-29',
  1600000,
  'wire_transfer',
  '2024-10-15',
  '2024-11-29',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0178',
  '2024-10-26',
  1900000,
  'wire_transfer',
  '2024-09-11',
  '2024-10-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  'INV-HWM-2024-0123',
  '2024-09-23',
  1350000,
  'wire_transfer',
  '2024-08-09',
  '2024-09-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0489',
  '2025-01-16',
  1600000,
  'wire_transfer',
  '2024-12-02',
  '2025-01-16',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0412',
  '2024-12-03',
  1200000,
  'wire_transfer',
  '2024-10-19',
  '2024-12-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0334',
  '2024-10-30',
  1500000,
  'wire_transfer',
  '2024-09-15',
  '2024-10-30',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  'INV-TDG-2024-0256',
  '2024-09-27',
  1100000,
  'wire_transfer',
  '2024-08-13',
  '2024-09-27',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2024-0167',
  '2025-01-21',
  1100000,
  'wire_transfer',
  '2024-12-07',
  '2025-01-21',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2024-0089',
  '2024-12-09',
  980000,
  'wire_transfer',
  '2024-10-25',
  '2024-12-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2024-0012',
  '2024-11-04',
  1250000,
  'wire_transfer',
  '2024-09-20',
  '2024-11-04',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  'INV-SPR-2023-0867',
  '2024-10-02',
  900000,
  'wire_transfer',
  '2024-08-18',
  '2024-10-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'INV-CW-2024-0245',
  '2025-01-19',
  1150000,
  'wire_transfer',
  '2024-12-05',
  '2025-01-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'INV-CW-2024-0178',
  '2024-12-06',
  950000,
  'wire_transfer',
  '2024-10-22',
  '2024-12-06',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  'INV-CW-2024-0112',
  '2024-11-03',
  1300000,
  'wire_transfer',
  '2024-09-19',
  '2024-11-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'INV-WWD-2024-0389',
  '2025-01-16',
  850000,
  'wire_transfer',
  '2024-12-02',
  '2025-01-16',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'INV-WWD-2024-0312',
  '2024-12-03',
  700000,
  'wire_transfer',
  '2024-10-19',
  '2024-12-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  'INV-WWD-2024-0234',
  '2024-10-30',
  950000,
  'wire_transfer',
  '2024-09-15',
  '2024-10-30',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'INV-MOG-2024-0234',
  '2025-01-21',
  720000,
  'wire_transfer',
  '2024-12-07',
  '2025-01-21',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'INV-MOG-2024-0167',
  '2024-12-08',
  580000,
  'wire_transfer',
  '2024-10-24',
  '2024-12-08',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  'INV-MOG-2024-0089',
  '2024-11-05',
  650000,
  'wire_transfer',
  '2024-09-21',
  '2024-11-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'INV-HEI-2024-0178',
  '2025-01-29',
  860000,
  'wire_transfer',
  '2024-12-15',
  '2025-01-29',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'INV-HEI-2024-0112',
  '2024-12-16',
  720000,
  'wire_transfer',
  '2024-11-01',
  '2024-12-16',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  'INV-HEI-2024-0045',
  '2024-11-13',
  650000,
  'wire_transfer',
  '2024-09-29',
  '2024-11-13',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'INV-DCO-2024-0112',
  '2025-01-26',
  520000,
  'wire_transfer',
  '2024-12-12',
  '2025-01-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'INV-DCO-2024-0056',
  '2024-12-13',
  420000,
  'wire_transfer',
  '2024-10-29',
  '2024-12-13',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  'INV-DCO-2023-0989',
  '2024-11-10',
  480000,
  'ach',
  '2024-09-26',
  '2024-11-10',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'INV-GTLS-2024-0167',
  '2025-01-19',
  800000,
  'wire_transfer',
  '2024-12-05',
  '2025-01-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'INV-GTLS-2024-0089',
  '2024-12-06',
  650000,
  'wire_transfer',
  '2024-10-22',
  '2024-12-06',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  'INV-GTLS-2024-0012',
  '2024-11-03',
  700000,
  'wire_transfer',
  '2024-09-19',
  '2024-11-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'INV-HAYN-2024-0089',
  '2025-02-15',
  490000,
  'ach',
  '2025-01-16',
  '2025-02-15',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'INV-HAYN-2024-0056',
  '2025-01-16',
  310000,
  'ach',
  '2024-12-17',
  '2025-01-16',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  'INV-HAYN-2024-0023',
  '2024-12-17',
  420000,
  'ach',
  '2024-11-17',
  '2024-12-17',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'INV-WTS-2024-0134',
  '2025-01-25',
  650000,
  'ach',
  '2024-12-11',
  '2025-01-25',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'INV-WTS-2024-0078',
  '2024-12-12',
  480000,
  'ach',
  '2024-10-28',
  '2024-12-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  'INV-WTS-2024-0012',
  '2024-11-09',
  550000,
  'ach',
  '2024-09-25',
  '2024-11-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'INV-CIR-2024-0145',
  '2025-02-05',
  410000,
  'wire_transfer',
  '2024-12-22',
  '2025-02-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'INV-CIR-2024-0089',
  '2024-12-23',
  320000,
  'wire_transfer',
  '2024-11-08',
  '2024-12-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  'INV-CIR-2024-0034',
  '2024-11-20',
  360000,
  'wire_transfer',
  '2024-10-06',
  '2024-11-20',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'INV-NRDM-2024-0167',
  '2025-01-18',
  620000,
  'wire_transfer',
  '2024-12-04',
  '2025-01-18',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'INV-NRDM-2024-0089',
  '2024-12-05',
  490000,
  'wire_transfer',
  '2024-10-21',
  '2024-12-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  'INV-NRDM-2024-0012',
  '2024-11-02',
  560000,
  'wire_transfer',
  '2024-09-18',
  '2024-11-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0378',
  '2025-01-08',
  320000,
  'wire_transfer',
  '2024-10-11',
  '2024-11-25',
  89,
  -44,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0312',
  '2024-12-12',
  280000,
  'wire_transfer',
  '2024-09-12',
  '2024-10-27',
  91,
  -46,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0245',
  '2024-11-05',
  450000,
  'wire_transfer',
  '2024-08-09',
  '2024-09-23',
  88,
  -43,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0178',
  '2024-09-20',
  520000,
  'wire_transfer',
  '2024-07-06',
  '2024-08-20',
  76,
  -31,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0112',
  '2024-08-10',
  480000,
  'wire_transfer',
  '2024-05-22',
  '2024-07-06',
  80,
  -35,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0045',
  '2024-06-15',
  650000,
  'wire_transfer',
  '2024-03-18',
  '2024-05-02',
  89,
  -44,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0189',
  '2025-01-30',
  480000,
  'wire_transfer',
  '2024-10-16',
  '2024-11-30',
  106,
  -61,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0134',
  '2024-12-15',
  540000,
  'wire_transfer',
  '2024-08-22',
  '2024-10-06',
  115,
  -70,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  'INV-TGI-2024-0078',
  '2024-10-20',
  490000,
  'wire_transfer',
  '2024-06-27',
  '2024-08-11',
  115,
  -70,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0312',
  '2025-01-12',
  450000,
  'wire_transfer',
  '2024-10-04',
  '2024-11-18',
  99,
  -54,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0245',
  '2024-12-05',
  380000,
  'wire_transfer',
  '2024-08-17',
  '2024-10-01',
  110,
  -65,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0178',
  '2024-10-22',
  520000,
  'wire_transfer',
  '2024-07-04',
  '2024-08-18',
  110,
  -65,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0112',
  '2024-09-01',
  480000,
  'wire_transfer',
  '2024-05-20',
  '2024-07-04',
  104,
  -59,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  'INV-KAMN-2024-0045',
  '2024-07-10',
  550000,
  'wire_transfer',
  '2024-03-26',
  '2024-05-10',
  106,
  -61,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2024-0145',
  '2024-12-01',
  80000,
  'wire_transfer',
  '2024-09-05',
  '2024-10-05',
  87,
  -57,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2024-0089',
  '2024-10-15',
  120000,
  'wire_transfer',
  '2024-07-15',
  '2024-08-14',
  92,
  -62,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2024-0034',
  '2024-08-20',
  180000,
  'wire_transfer',
  '2024-05-15',
  '2024-06-14',
  97,
  -67,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  'INV-OEG-2023-0889',
  '2024-06-01',
  210000,
  'check',
  '2024-03-01',
  '2024-03-31',
  92,
  -62,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2024-0223',
  '2025-01-22',
  95000,
  'check',
  '2024-10-09',
  '2024-11-23',
  105,
  -60,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2024-0156',
  '2024-11-18',
  140000,
  'check',
  '2024-07-26',
  '2024-09-09',
  115,
  -70,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  'INV-GLPW-2024-0089',
  '2024-09-12',
  180000,
  'check',
  '2024-05-30',
  '2024-07-14',
  105,
  -60,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0267',
  '2024-12-28',
  195000,
  'ach',
  '2024-11-05',
  '2024-12-05',
  53,
  -23,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0212',
  '2024-11-20',
  160000,
  'ach',
  '2024-09-30',
  '2024-10-30',
  51,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0156',
  '2024-10-15',
  195000,
  'ach',
  '2024-08-24',
  '2024-09-23',
  52,
  -22,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0089',
  '2024-08-28',
  210000,
  'ach',
  '2024-07-08',
  '2024-08-07',
  51,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  'INV-VTNR-2024-0023',
  '2024-07-05',
  185000,
  'ach',
  '2024-05-15',
  '2024-06-14',
  51,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2024-0312',
  '2024-12-28',
  350000,
  'wire_transfer',
  '2024-10-03',
  '2024-11-17',
  86,
  -41,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2024-0234',
  '2024-11-10',
  410000,
  'wire_transfer',
  '2024-07-29',
  '2024-09-12',
  104,
  -59,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2024-0156',
  '2024-09-05',
  360000,
  'wire_transfer',
  '2024-06-12',
  '2024-07-27',
  85,
  -40,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  'INV-PUMP-2024-0078',
  '2024-07-01',
  290000,
  'wire_transfer',
  '2024-04-16',
  '2024-05-31',
  76,
  -31,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2024-0234',
  '2024-12-22',
  120000,
  'check',
  '2024-10-17',
  '2024-11-16',
  66,
  -36,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2024-0178',
  '2024-11-05',
  145000,
  'check',
  '2024-08-22',
  '2024-09-21',
  75,
  -45,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  'INV-RNGR-2024-0112',
  '2024-09-10',
  130000,
  'check',
  '2024-06-27',
  '2024-07-27',
  75,
  -45,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2024-0145',
  '2025-01-10',
  200000,
  'wire_transfer',
  '2024-10-26',
  '2024-12-10',
  76,
  -31,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2024-0089',
  '2024-12-01',
  180000,
  'wire_transfer',
  '2024-08-22',
  '2024-10-06',
  101,
  -56,
  FALSE,
  TRUE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  'INV-NRDM-L-2024-0034',
  '2024-10-08',
  220000,
  'wire_transfer',
  '2024-06-19',
  '2024-08-03',
  111,
  -66,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0445',
  '2025-01-28',
  1100000,
  'wire_transfer',
  '2024-11-08',
  '2024-12-23',
  81,
  -36,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0378',
  '2024-12-10',
  1300000,
  'wire_transfer',
  '2024-09-18',
  '2024-11-02',
  83,
  -38,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0312',
  '2024-10-20',
  1450000,
  'wire_transfer',
  '2024-07-23',
  '2024-09-06',
  89,
  -44,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0234',
  '2024-08-15',
  1200000,
  'wire_transfer',
  '2024-05-27',
  '2024-07-11',
  80,
  -35,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  'INV-ARNC-2024-0156',
  '2024-06-20',
  1100000,
  'wire_transfer',
  '2024-03-28',
  '2024-05-12',
  84,
  -39,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0378',
  '2024-12-20',
  620000,
  'wire_transfer',
  '2024-09-30',
  '2024-11-14',
  81,
  -36,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0312',
  '2024-10-28',
  720000,
  'wire_transfer',
  '2024-07-15',
  '2024-08-29',
  105,
  -60,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0234',
  '2024-08-22',
  650000,
  'wire_transfer',
  '2024-05-09',
  '2024-06-23',
  105,
  -60,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  'INV-MDR-2024-0156',
  '2024-06-10',
  680000,
  'wire_transfer',
  '2024-03-05',
  '2024-04-19',
  97,
  -52,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2024-0267',
  '2025-01-12',
  340000,
  'ach',
  '2024-10-22',
  '2024-12-06',
  82,
  -37,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2024-0189',
  '2024-11-25',
  290000,
  'ach',
  '2024-08-12',
  '2024-09-26',
  105,
  -60,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2024-0112',
  '2024-09-30',
  320000,
  'ach',
  '2024-06-15',
  '2024-07-30',
  107,
  -62,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  'INV-SUP-2024-0034',
  '2024-07-20',
  300000,
  'ach',
  '2024-04-06',
  '2024-05-21',
  105,
  -60,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2024-0212',
  '2025-01-22',
  380000,
  'wire_transfer',
  '2024-11-08',
  '2024-12-23',
  75,
  -30,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2024-0145',
  '2024-12-10',
  350000,
  'wire_transfer',
  '2024-09-18',
  '2024-11-02',
  83,
  -38,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2024-0078',
  '2024-10-20',
  410000,
  'wire_transfer',
  '2024-07-25',
  '2024-09-08',
  87,
  -42,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  'INV-CDE-2024-0012',
  '2024-08-10',
  350000,
  'wire_transfer',
  '2024-05-20',
  '2024-07-04',
  82,
  -37,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2024-0145',
  '2025-01-05',
  250000,
  'ach',
  '2024-10-15',
  '2024-11-29',
  82,
  -37,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2024-0089',
  '2024-11-18',
  220000,
  'ach',
  '2024-08-14',
  '2024-09-28',
  96,
  -51,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  'INV-MG-2024-0034',
  '2024-09-25',
  240000,
  'ach',
  '2024-06-10',
  '2024-07-25',
  107,
  -62,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0489',
  '2025-01-08',
  1200000,
  'wire_transfer',
  '2024-10-21',
  '2024-12-20',
  79,
  -10,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0412',
  '2024-12-05',
  980000,
  'wire_transfer',
  '2024-09-12',
  '2024-11-11',
  84,
  -15,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0334',
  '2024-11-01',
  1100000,
  'wire_transfer',
  '2024-08-02',
  '2024-10-01',
  91,
  -22,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0256',
  '2024-09-25',
  1050000,
  'wire_transfer',
  '2024-06-27',
  '2024-08-26',
  90,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  'INV-GE-2024-0178',
  '2024-08-20',
  1300000,
  'wire_transfer',
  '2024-05-22',
  '2024-07-21',
  90,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0289',
  '2024-10-28',
  650000,
  'wire_transfer',
  '2024-09-01',
  '2024-10-16',
  57,
  -12,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0212',
  '2024-09-18',
  480000,
  'wire_transfer',
  '2024-07-18',
  '2024-09-01',
  62,
  -17,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0145',
  '2024-08-05',
  550000,
  'wire_transfer',
  '2024-06-04',
  '2024-07-19',
  62,
  -17,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  'INV-SAVE-2024-0078',
  '2024-06-20',
  490000,
  'wire_transfer',
  '2024-04-10',
  '2024-05-25',
  71,
  -26,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0612',
  '2025-01-02',
  950000,
  'wire_transfer',
  '2024-11-18',
  '2025-01-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0545',
  '2024-11-19',
  850000,
  'wire_transfer',
  '2024-10-05',
  '2024-11-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0478',
  '2024-10-16',
  980000,
  'wire_transfer',
  '2024-09-01',
  '2024-10-16',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0412',
  '2024-09-13',
  820000,
  'wire_transfer',
  '2024-07-30',
  '2024-09-13',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  'INV-ACM-2024-0345',
  '2024-08-10',
  1100000,
  'wire_transfer',
  '2024-06-26',
  '2024-08-10',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2024-0145',
  '2024-12-28',
  200000,
  'wire_transfer',
  '2024-10-24',
  '2024-12-08',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2024-0089',
  '2024-11-15',
  185000,
  'wire_transfer',
  '2024-09-09',
  '2024-10-24',
  66,
  -21,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2024-0034',
  '2024-09-20',
  210000,
  'wire_transfer',
  '2024-07-04',
  '2024-08-18',
  78,
  -33,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  'INV-LIQT-2023-0889',
  '2024-07-25',
  195000,
  'wire_transfer',
  '2024-05-01',
  '2024-06-15',
  85,
  -40,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0701',
  '2025-01-05',
  1600000,
  'wire_transfer',
  '2024-11-21',
  '2025-01-05',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0634',
  '2024-11-22',
  1400000,
  'wire_transfer',
  '2024-10-08',
  '2024-11-22',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0567',
  '2024-10-19',
  1800000,
  'wire_transfer',
  '2024-09-04',
  '2024-10-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0501',
  '2024-09-16',
  1500000,
  'wire_transfer',
  '2024-08-02',
  '2024-09-16',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  'INV-AAL-2024-0434',
  '2024-08-13',
  1700000,
  'wire_transfer',
  '2024-06-29',
  '2024-08-13',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0489',
  '2025-01-09',
  820000,
  'wire_transfer',
  '2024-11-25',
  '2025-01-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0423',
  '2024-11-26',
  750000,
  'wire_transfer',
  '2024-10-12',
  '2024-11-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0356',
  '2024-10-23',
  900000,
  'wire_transfer',
  '2024-09-08',
  '2024-10-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0289',
  '2024-09-20',
  680000,
  'wire_transfer',
  '2024-08-06',
  '2024-09-20',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  'INV-MAXR-2024-0222',
  '2024-08-17',
  820000,
  'wire_transfer',
  '2024-07-03',
  '2024-08-17',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0289',
  '2023-10-05',
  380000,
  'wire_transfer',
  '2023-08-08',
  '2023-09-22',
  58,
  -13,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0212',
  '2023-08-28',
  320000,
  'wire_transfer',
  '2023-06-15',
  '2023-07-30',
  74,
  -29,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  'INV-RAD-2023-0145',
  '2023-07-10',
  410000,
  'wire_transfer',
  '2023-04-28',
  '2023-06-12',
  73,
  -28,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'INV-YELLQ-2023-0145',
  '2023-07-20',
  280000,
  'wire_transfer',
  '2023-05-24',
  '2023-07-08',
  57,
  -12,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'INV-YELLQ-2023-0078',
  '2023-06-10',
  320000,
  'wire_transfer',
  '2023-03-30',
  '2023-05-14',
  72,
  -27,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  'INV-YELLQ-2023-0012',
  '2023-04-25',
  290000,
  'wire_transfer',
  '2023-02-14',
  '2023-03-31',
  70,
  -25,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'INV-PTRA-2023-0156',
  '2023-07-15',
  240000,
  'wire_transfer',
  '2023-05-12',
  '2023-06-26',
  64,
  -19,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'INV-PTRA-2023-0089',
  '2023-05-30',
  310000,
  'wire_transfer',
  '2023-03-16',
  '2023-04-30',
  75,
  -30,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  'INV-PTRA-2023-0023',
  '2023-04-12',
  280000,
  'wire_transfer',
  '2023-02-01',
  '2023-03-18',
  70,
  -25,
  FALSE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2024-0089',
  '2025-01-19',
  195000,
  'wire_transfer',
  '2024-12-05',
  '2025-01-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2024-0034',
  '2024-12-06',
  170000,
  'wire_transfer',
  '2024-10-22',
  '2024-12-06',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2024-0012',
  '2024-11-03',
  210000,
  'wire_transfer',
  '2024-09-19',
  '2024-11-03',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'INV-JOBY-2023-0889',
  '2024-10-01',
  185000,
  'wire_transfer',
  '2024-08-17',
  '2024-10-01',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'INV-ACHR-2024-0089',
  '2025-01-25',
  160000,
  'wire_transfer',
  '2024-12-11',
  '2025-01-25',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'INV-ACHR-2024-0056',
  '2024-12-12',
  140000,
  'wire_transfer',
  '2024-10-28',
  '2024-12-12',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'INV-ACHR-2024-0023',
  '2024-11-09',
  170000,
  'wire_transfer',
  '2024-09-25',
  '2024-11-09',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0234',
  '2025-01-07',
  1400000,
  'wire_transfer',
  '2024-11-23',
  '2025-01-07',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0178',
  '2024-11-24',
  1200000,
  'wire_transfer',
  '2024-10-10',
  '2024-11-24',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0123',
  '2024-10-21',
  1550000,
  'wire_transfer',
  '2024-09-06',
  '2024-10-21',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'INV-GEV-2024-0067',
  '2024-09-18',
  1100000,
  'wire_transfer',
  '2024-08-04',
  '2024-09-18',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0412',
  '2025-01-15',
  1050000,
  'wire_transfer',
  '2024-12-01',
  '2025-01-15',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0334',
  '2024-12-02',
  880000,
  'wire_transfer',
  '2024-10-18',
  '2024-12-02',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0256',
  '2024-10-29',
  1100000,
  'wire_transfer',
  '2024-09-14',
  '2024-10-29',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0178',
  '2024-09-26',
  920000,
  'wire_transfer',
  '2024-08-12',
  '2024-09-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'INV-DRS-2024-0101',
  '2024-08-23',
  980000,
  'wire_transfer',
  '2024-07-09',
  '2024-08-23',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0234',
  '2025-01-17',
  620000,
  'wire_transfer',
  '2024-12-03',
  '2025-01-17',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0178',
  '2024-12-04',
  540000,
  'wire_transfer',
  '2024-10-20',
  '2024-12-04',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0123',
  '2024-11-01',
  590000,
  'wire_transfer',
  '2024-09-17',
  '2024-11-01',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0067',
  '2024-09-29',
  510000,
  'wire_transfer',
  '2024-08-15',
  '2024-09-29',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'INV-BE-2024-0012',
  '2024-08-26',
  480000,
  'wire_transfer',
  '2024-07-12',
  '2024-08-26',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0612',
  '2025-01-11',
  1800000,
  'wire_transfer',
  '2024-11-27',
  '2025-01-11',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0545',
  '2024-11-28',
  1500000,
  'wire_transfer',
  '2024-10-14',
  '2024-11-28',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0478',
  '2024-10-25',
  1700000,
  'wire_transfer',
  '2024-09-10',
  '2024-10-25',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0412',
  '2024-09-22',
  1400000,
  'wire_transfer',
  '2024-08-08',
  '2024-09-22',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  'INV-TXT-2024-0345',
  '2024-08-19',
  1650000,
  'wire_transfer',
  '2024-07-05',
  '2024-08-19',
  45,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2024-0145',
  '2024-12-10',
  220000,
  'ach',
  '2024-11-10',
  '2024-12-10',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2024-0089',
  '2024-11-11',
  195000,
  'ach',
  '2024-10-12',
  '2024-11-11',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2024-0034',
  '2024-10-13',
  240000,
  'ach',
  '2024-09-13',
  '2024-10-13',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);
INSERT INTO payment_transactions (
  customer_id, invoice_number, payment_date, amount_paid,
  payment_method, invoice_date, invoice_due_date,
  days_to_pay, days_early_late, paid_on_time,
  is_partial_payment, posted_by
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  'INV-HLGN-2023-0889',
  '2024-09-14',
  180000,
  'ach',
  '2024-08-15',
  '2024-09-14',
  30,
  0,
  TRUE,
  FALSE,
  'system'
);

-- CREDIT METRICS
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  780,
  '5A1',
  3.1,
  8.2,
  1.18,
  2.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  810,
  '5A1',
  3.8,
  0.68,
  1.32,
  8.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  825,
  '5A1',
  4.1,
  0.95,
  1.28,
  15.3,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  800,
  '5A1',
  3.9,
  0.88,
  1.41,
  10.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  820,
  '5A1',
  4.2,
  0.45,
  1.72,
  18.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  770,
  '5A1',
  3.2,
  0.42,
  1.58,
  7.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  765,
  '4A1',
  3.0,
  1.45,
  1.22,
  6.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  795,
  '4A1',
  3.6,
  0.72,
  1.55,
  11.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  760,
  '5A2',
  2.8,
  12.4,
  2.1,
  3.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  695,
  '3A2',
  2.3,
  3.1,
  1.08,
  2.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  775,
  '4A1',
  3.4,
  0.61,
  1.62,
  12.7,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  755,
  '4A1',
  3.3,
  0.82,
  1.48,
  9.1,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  760,
  '3A1',
  3.2,
  1.02,
  1.52,
  7.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  810,
  '4A1',
  4.5,
  0.55,
  2.1,
  22.1,
  '2024-10-31',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  740,
  '2A2',
  2.9,
  1.62,
  1.38,
  5.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  720,
  '3A2',
  2.6,
  2.14,
  1.31,
  3.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  780,
  '2A1',
  3.8,
  0.28,
  2.45,
  14.2,
  '2024-12-31',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  750,
  '3A1',
  3.1,
  0.71,
  1.67,
  8.9,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  735,
  '2A2',
  2.8,
  1.34,
  1.44,
  5.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  695,
  '2A2',
  NULL,
  NULL,
  1.28,
  4.2,
  '2024-12-31',
  'customer_supplied'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  548,
  '2A4',
  1.4,
  8.2,
  0.88,
  1.1,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  582,
  '2A4',
  1.7,
  5.8,
  1.02,
  1.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  412,
  'BB4',
  0.8,
  -2.1,
  0.62,
  -0.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  498,
  '1A4',
  1.2,
  4.8,
  0.78,
  0.9,
  '2024-06-30',
  'customer_supplied'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  521,
  '1A4',
  1.1,
  6.2,
  0.91,
  1.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  580,
  '2A3',
  1.9,
  2.8,
  1.05,
  2.1,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  495,
  '1A4',
  1.5,
  3.2,
  0.98,
  1.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  552,
  '1A3',
  NULL,
  NULL,
  1.05,
  2.8,
  '2024-12-31',
  'customer_supplied'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  598,
  '3A4',
  1.6,
  4.8,
  1.12,
  1.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  488,
  '1A4',
  0.9,
  15.2,
  0.74,
  0.6,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  524,
  '1A4',
  1.2,
  11.8,
  0.88,
  0.8,
  '2024-12-31',
  'SEC_10K'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  601,
  '2A3',
  1.8,
  0.62,
  1.22,
  2.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  572,
  '2A4',
  1.5,
  2.8,
  1.18,
  2.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  780,
  '5A1',
  3.4,
  0.88,
  1.22,
  5.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  310,
  'BB4',
  0.4,
  -3.8,
  0.45,
  -1.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  720,
  '4A2',
  3.2,
  0.92,
  1.38,
  6.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  488,
  '1A3',
  1.1,
  1.8,
  0.95,
  1.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  620,
  '4A3',
  2.1,
  8.4,
  0.82,
  2.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  720,
  '3A2',
  2.8,
  2.4,
  1.35,
  4.1,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  180,
  'BB4',
  0.1,
  -8.2,
  0.38,
  -2.1,
  '2023-08-31',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  120,
  'BB4',
  0.0,
  -15.2,
  0.22,
  -4.8,
  '2023-06-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  185,
  '1A4',
  0.2,
  NULL,
  0.41,
  -1.8,
  '2023-06-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  720,
  '2A1',
  NULL,
  NULL,
  8.4,
  NULL,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  680,
  '2A1',
  NULL,
  NULL,
  12.1,
  NULL,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  800,
  '5A1',
  3.8,
  0.65,
  1.42,
  8.2,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  800,
  '4A1',
  3.9,
  0.55,
  1.68,
  11.4,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  700,
  '3A2',
  2.4,
  1.2,
  1.88,
  4.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  800,
  '5A1',
  3.7,
  0.78,
  1.45,
  9.8,
  '2024-12-31',
  'SEC_10K'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO credit_metrics (
  customer_id, credit_score, d_and_b_rating, altman_z_score,
  debt_to_equity, current_ratio, interest_coverage,
  last_financials_date, financials_source
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  420,
  '1A4',
  0.6,
  NULL,
  0.58,
  -0.8,
  '2024-09-30',
  'SEC_10Q'
) ON CONFLICT (customer_id) DO NOTHING;

-- AR AGING SNAPSHOTS
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000001',
  '2025-02-22',
  5200000,
  0,
  0,
  0,
  0,
  0,
  8000000,
  65.0,
  42.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000002',
  '2025-02-22',
  4800000,
  0,
  0,
  0,
  0,
  0,
  7500000,
  64.0,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000003',
  '2025-02-22',
  4100000,
  0,
  0,
  0,
  0,
  0,
  6500000,
  63.1,
  39.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000004',
  '2025-02-22',
  2200000,
  0,
  0,
  0,
  0,
  0,
  3000000,
  73.3,
  38.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000005',
  '2025-02-22',
  3800000,
  0,
  0,
  0,
  0,
  0,
  5000000,
  76.0,
  41.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000006',
  '2025-02-22',
  2800000,
  0,
  0,
  0,
  0,
  0,
  4000000,
  70.0,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000007',
  '2025-02-22',
  2600000,
  0,
  0,
  0,
  0,
  0,
  3500000,
  74.3,
  41.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000008',
  '2025-02-22',
  3200000,
  0,
  0,
  0,
  0,
  0,
  4500000,
  71.1,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000009',
  '2025-02-22',
  2400000,
  0,
  0,
  0,
  0,
  0,
  3500000,
  68.6,
  39.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000010',
  '2025-02-22',
  2100000,
  0,
  0,
  0,
  0,
  0,
  3000000,
  70.0,
  41.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000011',
  '2025-02-22',
  1700000,
  0,
  0,
  0,
  0,
  0,
  2500000,
  68.0,
  39.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000012',
  '2025-02-22',
  1400000,
  0,
  0,
  0,
  0,
  0,
  2000000,
  70.0,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000013',
  '2025-02-22',
  1050000,
  0,
  0,
  0,
  0,
  0,
  1500000,
  70.0,
  39.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000014',
  '2025-02-22',
  1300000,
  0,
  0,
  0,
  0,
  0,
  2000000,
  65.0,
  38.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000015',
  '2025-02-22',
  780000,
  0,
  0,
  0,
  0,
  0,
  1200000,
  65.0,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000016',
  '2025-02-22',
  1200000,
  0,
  0,
  0,
  0,
  0,
  1800000,
  66.7,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000017',
  '2025-02-22',
  780000,
  0,
  0,
  0,
  0,
  0,
  1200000,
  65.0,
  32.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000018',
  '2025-02-22',
  950000,
  0,
  0,
  0,
  0,
  0,
  1500000,
  63.3,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000019',
  '2025-02-22',
  620000,
  0,
  0,
  0,
  0,
  0,
  1000000,
  62.0,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000020',
  '2025-02-22',
  950000,
  0,
  0,
  0,
  0,
  0,
  1500000,
  63.3,
  40.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-22',
  200000,
  420000,
  580000,
  650000,
  0,
  0,
  2000000,
  92.5,
  78.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  '2025-02-22',
  400000,
  530000,
  720000,
  0,
  0,
  0,
  1800000,
  91.7,
  68.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-02-22',
  0,
  125000,
  245000,
  310000,
  0,
  0,
  750000,
  90.7,
  82.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  '2025-02-22',
  87000,
  185000,
  280000,
  0,
  0,
  0,
  600000,
  92.0,
  72.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  '2025-02-22',
  85000,
  135000,
  225000,
  0,
  0,
  0,
  500000,
  89.0,
  51.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  '2025-02-22',
  330000,
  380000,
  0,
  0,
  0,
  0,
  800000,
  88.8,
  57.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  '2025-02-22',
  75000,
  125000,
  175000,
  0,
  0,
  0,
  400000,
  93.8,
  62.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  '2025-02-22',
  110000,
  215000,
  185000,
  0,
  0,
  0,
  500000,
  102.0,
  58.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-02-22',
  1550000,
  1200000,
  0,
  0,
  0,
  0,
  3000000,
  91.7,
  52.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-02-22',
  250000,
  680000,
  450000,
  0,
  0,
  0,
  1500000,
  92.0,
  62.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-02-22',
  340000,
  380000,
  0,
  0,
  0,
  0,
  800000,
  90.0,
  54.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-02-22',
  470000,
  420000,
  0,
  0,
  0,
  0,
  1000000,
  89.0,
  50.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2025-02-22',
  255000,
  290000,
  0,
  0,
  0,
  0,
  600000,
  90.8,
  56.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  '2025-02-22',
  2200000,
  0,
  0,
  0,
  0,
  0,
  2500000,
  88.0,
  60.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2025-02-22',
  0,
  0,
  0,
  0,
  0,
  1080000,
  1200000,
  90.0,
  NULL,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-02-22',
  750000,
  900000,
  0,
  0,
  0,
  0,
  2000000,
  82.5,
  48.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-02-22',
  140000,
  225000,
  0,
  0,
  0,
  0,
  400000,
  91.3,
  54.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  '2025-02-22',
  2400000,
  0,
  0,
  0,
  0,
  0,
  3000000,
  80.0,
  44.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2025-02-22',
  1250000,
  0,
  0,
  0,
  0,
  0,
  1500000,
  83.3,
  44.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2025-02-22',
  0,
  0,
  0,
  0,
  0,
  487000,
  500000,
  97.4,
  NULL,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2025-02-22',
  0,
  0,
  0,
  0,
  0,
  298000,
  600000,
  49.7,
  NULL,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2025-02-22',
  0,
  0,
  0,
  0,
  0,
  378000,
  500000,
  75.6,
  NULL,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  '2025-02-22',
  280000,
  0,
  0,
  0,
  0,
  0,
  500000,
  56.0,
  45.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  '2025-02-22',
  220000,
  0,
  0,
  0,
  0,
  0,
  400000,
  55.0,
  44.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  '2025-02-22',
  2200000,
  0,
  0,
  0,
  0,
  0,
  3000000,
  73.3,
  43.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  '2025-02-22',
  1600000,
  0,
  0,
  0,
  0,
  0,
  2000000,
  80.0,
  44.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  '2025-02-22',
  980000,
  0,
  0,
  0,
  0,
  0,
  1500000,
  65.3,
  44.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  '2025-02-22',
  2800000,
  0,
  0,
  0,
  0,
  0,
  4000000,
  70.0,
  43.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;
INSERT INTO ar_aging_snapshots (
  customer_id, snapshot_date,
  current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
  pre_petition_amount, credit_limit, utilization_pct, dso_days, generated_by
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-02-22',
  0,
  250000,
  170000,
  0,
  0,
  0,
  600000,
  70.0,
  34.0,
  'seed'
) ON CONFLICT (customer_id, snapshot_date) DO NOTHING;

-- NEGATIVE NEWS
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  'Triumph Group CEO to depart amid ongoing restructuring',
  'Bloomberg',
  -0.72,
  'CEO Daniel Crowley announced departure effective Q1 2025; board to conduct executive search amid turnaround effort',
  'management',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-05',
  'Triumph Group considers asset sales to shore up balance sheet',
  'Reuters',
  -0.65,
  'Strategic review could result in divestiture of defense structures segment to raise cash and reduce debt',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  'Triumph Group 10-Q reveals covenant waiver, pension deficit and strategic review',
  'SEC Filing',
  -0.84,
  'Quarterly filing discloses covenant waiver, $84M pension underfunding, CEO departure and ongoing strategic portfolio review. Multiple concurrent risk factors elevate concern level.',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  '2025-01-05',
  'Kaman aerospace unit faces cash flow pressure after distribution sale',
  'Aviation Week',
  -0.58,
  'Following the $700M distribution divestiture, the remaining aerospace manufacturing business is showing signs of working capital stress',
  'financial',
  'medium',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-01-12',
  'Orbital Energy Group faces acute liquidity crisis, collections action initiated',
  'Internal',
  -0.95,
  'Account referred to external collections. CEO requesting payment plan. Company may be approaching insolvency.',
  'financial',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-01-15',
  'Moody''s downgrades Arconic to B1 on weak aluminum pricing and elevated leverage',
  'Moodys',
  -0.82,
  'Rating action cites deteriorating credit metrics, covenant amendment in Q4 2024, and limited ability to deleverage in a weak pricing environment',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-01-29',
  'Arconic Q4 earnings disappoint; 2025 guidance cut substantially',
  'Bloomberg',
  -0.71,
  'Q4 EBITDA came in 22% below consensus. Management reduced 2025 guidance citing ongoing aluminum pricing weakness and higher energy costs',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-08',
  'S&P cuts McDermott to CCC+ as restructuring risk rises',
  'S&P Global',
  -0.91,
  'Second major downgrade in six months. S&P cites inadequate liquidity, execution risk on LNG projects, and rising probability of another restructuring event',
  'financial',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-22',
  'McDermott retains Lazard and Kirkland for debt restructuring review',
  'Reuters',
  -0.95,
  'Engagement of top-tier restructuring advisors signals high probability of balance sheet restructuring. Company had previously filed Chapter 11 in 2019',
  'financial',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-02-01',
  'Superior Industries suspends dividend after Q4 earnings miss, announces cost cuts',
  'Bloomberg',
  -0.77,
  'Q4 EBITDA missed by 31%. Management suspended dividend and announced 15% workforce reduction citing sustained weakness in European auto production volumes',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-01-20',
  'Fitch revises Coeur Mining outlook to negative after SilverCrest acquisition concerns',
  'Fitch Ratings',
  -0.68,
  'Fitch cites stretched balance sheet post-acquisition, silver price headwinds, and integration execution risk as drivers of the outlook revision',
  'financial',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2025-01-10',
  'Mistras Group CFO unexpectedly departs; interim appointed',
  'SEC Filing',
  -0.65,
  'CFO departure follows $42M goodwill impairment charge in Q3. Management succession uncertainty adds to existing financial pressures',
  'management',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-11-18',
  'Spirit Airlines files Chapter 11 bankruptcy, suspends all operations planning',
  'Reuters',
  -0.99,
  'Spirit Airlines filed for bankruptcy protection in New Jersey federal court. The airline is seeking to restructure its debt and operations. All vendor contracts under review',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2025-01-15',
  'Spirit Airlines restructuring plan faces creditor challenges',
  'Bloomberg',
  -0.85,
  'Spirit''s proposed reorganization plan faces objections from multiple creditor groups over recovery rates. Trade creditors expected to receive 15-30 cents on the dollar',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-14',
  'AECOM discloses SEC investigation into revenue recognition, delays 10-K filing',
  'WSJ',
  -0.88,
  'SEC opened formal investigation into how AECOM recognizes revenue on long-term government contracts. Company delayed filing its 10-K by 60 days to allow restatement review',
  'regulatory',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-28',
  'AECOM appoints outside counsel to lead SEC inquiry review',
  'Bloomberg',
  -0.71,
  'Company retained Sullivan & Cromwell for SEC matter, signaling seriousness of potential accounting irregularities. Analysts estimate $200-400M potential restatement impact',
  'regulatory',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2024-12-01',
  'Liqtech loses U.S. Navy filter contract worth 30% of revenue',
  'SEC Filing',
  -0.92,
  'U.S. Navy terminated silicon carbide membrane filter contract effective Dec 31 2024. Loss represents the single largest revenue source for the company',
  'operational',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-01-10',
  'Liqtech announces 25% headcount reduction following 45% revenue decline',
  'Reuters',
  -0.88,
  'Company confirms existential threat to current business model. Management exploring strategic alternatives including potential sale. Revenue fell 45% in latest quarter',
  'operational',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  '2025-02-08',
  'American Airlines cuts Q1 2025 revenue guidance citing demand softness',
  'Bloomberg',
  -0.62,
  'AAL lowered Q1 unit revenue guidance by 3.5% on softer than expected corporate and leisure travel demand. Analysts note structural challenges vs. Delta and United',
  'financial',
  'medium',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  '2025-01-20',
  'DOJ appeals court ruling on American-JetBlue alliance',
  'Reuters',
  -0.55,
  'Department of Justice is appealing a lower court ruling that permitted the American-JetBlue codeshare agreement in certain markets, creating continued regulatory uncertainty',
  'regulatory',
  'medium',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2024-03-15',
  'Maxar WorldView-3 satellite suffers anomaly, imagery capacity reduced 40%',
  'Space News',
  -0.81,
  'Technical anomaly on WorldView-3 commercial imaging satellite has reduced the company''s earth imaging capacity by approximately 40%. Insurance claim has been filed',
  'operational',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2025-01-10',
  'Maxar struggles to recover WorldView-3 capacity; NGA contract at risk',
  'Defense News',
  -0.72,
  'National Geospatial-Intelligence Agency has indicated potential contractual remedies if imagery SLAs are not restored by Q2 2025. Maxar disputes capacity estimates',
  'operational',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-10-15',
  'Rite Aid files Chapter 11 bankruptcy with $8.6 billion in liabilities',
  'WSJ',
  -0.99,
  'Rite Aid filed for bankruptcy protection after years of losses compounded by opioid litigation settlements. The company seeks to close underperforming stores and restructure debt',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2023-08-06',
  'Yellow Corporation files Chapter 11, ceasing all operations immediately',
  'Reuters',
  -0.99,
  'Yellow Corporation, once the third-largest LTL carrier in the US, filed for Chapter 11 and ceased all freight operations. 30,000 employees immediately laid off',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2024-03-15',
  'Yellow bankruptcy converted to Chapter 7; trustee appointed to liquidate assets',
  'Bloomberg',
  -0.9,
  'Court converted Yellow''s Chapter 11 to Chapter 7 liquidation. Trustee Edmond George appointed to oversee asset sales. Trade creditors expected 3-7 cent recovery',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2023-08-07',
  'Proterra files Chapter 11, blames supply chain costs and EV market timing',
  'Bloomberg',
  -0.95,
  'Electric bus maker Proterra filed for Chapter 11 protection citing inability to scale manufacturing profitably amid rising battery costs and intense competition',
  'bankruptcy',
  'critical',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2023-11-15',
  'Proterra 363 asset sales complete: NFI buys transit, Volvo takes battery unit',
  'Reuters',
  -0.6,
  'Bankruptcy court approved 363 asset sales. NFI Group acquired transit bus operations for $50M; Volvo acquired Powered by Proterra battery system business for $210M',
  'bankruptcy',
  'high',
  FALSE,
  'seed'
);
INSERT INTO negative_news (
  customer_id, news_date, headline, source,
  sentiment_score, summary, category, severity,
  reviewed, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-01-12',
  'Heliogen discloses going concern warning in 10-Q; 2.5 quarters of cash remaining',
  'SEC Filing',
  -0.92,
  '10-Q filing reveals going concern qualification. With $38M cash and $15M quarterly burn, company has approximately 2.5 quarters of runway without new capital or revenue',
  'financial',
  'critical',
  FALSE,
  'seed'
);

-- CREDIT EVENTS
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  'MANAGEMENT_CHANGE',
  'CEO Dan Crowley announced departure; Board appointed interim CEO',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-15',
  'COVENANT_WAIVER',
  'Obtained lender waiver on leverage ratio covenant through Q2 2025',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-05',
  'RESTRUCTURING_ANNOUNCEMENT',
  'Strategic review of portfolio underway; potential asset sales',
  'Reuters',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-01-15',
  'RATING_DOWNGRADE',
  'Moody''s downgraded ARNC to B1 from Ba3, citing elevated leverage and weak aluminum market pricing',
  'Moodys_Analytics',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-01-28',
  'EARNINGS_MISS',
  'Q4 2024 EBITDA missed consensus by 22%; lowered 2025 guidance',
  'SEC_EDGAR',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2024-11-05',
  'COVENANT_WAIVER',
  'Secured waiver from lenders on leverage ratio covenant through Q2 2025',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-08',
  'RATING_DOWNGRADE',
  'S&P downgraded to CCC+ from B-, outlook negative',
  'S&P_Global',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-22',
  'RESTRUCTURING_ANNOUNCEMENT',
  'Engaged restructuring advisors Lazard and Kirkland & Ellis',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2024-12-15',
  'LOAN_AMENDMENT',
  'Amended credit facility with restrictive covenants, 12 months additional runway',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-02-01',
  'EARNINGS_MISS',
  'Q4 missed by 31%, suspended dividend, announced cost reduction plan',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-01-15',
  'CREDIT_FACILITY_AMENDMENT',
  'Amended revolving credit facility with tighter covenants and reduced availability',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-01-20',
  'OUTLOOK_CHANGE',
  'Fitch changed outlook to negative on silver price weakness and SilverCrest integration risk',
  'Fitch_Ratings',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-01-28',
  'CAPITAL_RAISE',
  'Announced $200M equity offering at 8% discount to fund SilverCrest acquisition',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2025-01-10',
  'MANAGEMENT_CHANGE',
  'CFO departure announced; interim CFO appointed pending search',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2024-11-15',
  'GOODWILL_IMPAIRMENT',
  'Recorded $42M goodwill impairment charge related to Oil & Gas segment',
  'SEC_10Q',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  '2024-10-15',
  'OTHER',
  'GE Vernova spin-off completed April 2024; PO routing unclear for legacy contracts. Unilateral extension of payment terms from 45 to 60 days without agreement',
  'Internal',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-11-18',
  'OTHER',
  'Spirit Airlines filed Chapter 11 bankruptcy, Case 23-11993 District of New Jersey',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-14',
  'SEC_INVESTIGATION',
  'SEC opened formal investigation into revenue recognition practices on government contracts. 10-K filing delayed by 60 days',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2024-12-01',
  'CONTRACT_LOSS',
  'Lost U.S. Navy silicon carbide filter contract representing 30% of annual revenue. Effective December 31, 2024',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-01-10',
  'RESTRUCTURING_ANNOUNCEMENT',
  'Announced 25% workforce reduction following revenue collapse. Revenue declined 45% year-over-year',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2024-03-15',
  'OTHER',
  'WorldView-3 satellite anomaly resulted in 40% capacity reduction. Insurance claim filed for estimated $200-300M loss',
  'SEC_8K',
  'seed'
);
INSERT INTO credit_events (
  customer_id, event_date, event_type, detail, source, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-01-12',
  'GOING_CONCERN',
  '10-Q discloses going concern warning. Cash of $38M against $15M quarterly burn rate = 2.5 quarters runway. Seeking strategic alternatives.',
  'SEC_10Q',
  'seed'
);

-- CREDIT ACTIONS
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-15',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-20',
  'DUNNING_LETTER_STAGE_3',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  'DUNNING_LETTER_STAGE_2',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  'SEC_ALERT_TRIGGERED',
  'Multiple risk signals detected in 10-Q filing',
  'sec_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-30',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-01',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-05',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-05',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-02-10',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  '2025-01-20',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  '2025-01-25',
  'DUNNING_LETTER_STAGE_2',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000022',
  '2025-02-08',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-01-05',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-01-10',
  'REFERRED_TO_COLLECTIONS',
  NULL,
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-01-15',
  'COD_ONLY_POLICY_SET',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000023',
  '2025-02-01',
  'PAYMENT_PLAN_DISCUSSION',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  '2025-01-28',
  'DUNNING_LETTER_STAGE_2',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  '2025-02-05',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Michael Torres',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000024',
  '2025-02-10',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  '2025-01-30',
  'DUNNING_LETTER_STAGE_2',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000025',
  '2025-02-16',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  '2025-02-05',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000026',
  '2025-02-10',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Michael Torres',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  '2025-01-28',
  'DUNNING_LETTER_STAGE_2',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  '2025-02-05',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000027',
  '2025-02-14',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  '2025-02-01',
  'PARENT_GUARANTEE_REQUEST_SENT',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  '2025-02-05',
  'DUNNING_LETTER_STAGE_1',
  NULL,
  'system',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000028',
  '2025-02-12',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-01-20',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-02-01',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000029',
  '2025-02-10',
  'CREDIT_LIMIT_REDUCTION',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-10',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Michael Torres',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-01-22',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-02-01',
  'EXECUTIVE_ESCALATION',
  NULL,
  'CFO',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000030',
  '2025-02-05',
  'COD_ONLY_POLICY_SET',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-02-05',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000031',
  '2025-02-10',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-01-25',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Michael Torres',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000032',
  '2025-02-01',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2025-01-12',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000033',
  '2025-01-15',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  '2025-02-08',
  'PLACED_ON_WATCH_LIST',
  'Payment slowdown and entity ambiguity post-GEV spin-off',
  'Sarah Chen',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000034',
  '2025-02-08',
  'FINANCIALS_REQUEST_SENT',
  'Requested confirmation of entity responsible for legacy contracts',
  'Sarah Chen',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-11-18',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-11-19',
  'COD_ONLY_POLICY_SET',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-12-01',
  'PROOF_OF_CLAIM_FILED',
  'Proof of claim filed for $1,080,000 in pre-petition invoices',
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-15',
  'NEWS_ALERT_TRIGGERED',
  'SEC investigation detected',
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-20',
  'NEWS_MONITORING_INCREASED',
  NULL,
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000036',
  '2025-01-25',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Michael Torres',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-01-10',
  'NEWS_ALERT_TRIGGERED',
  NULL,
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-01-15',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000037',
  '2025-01-20',
  'CREDIT_REVIEW_INITIATED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  '2025-02-10',
  'NEWS_ALERT_TRIGGERED',
  'Guidance cut detected',
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000038',
  '2025-02-14',
  'NEWS_MONITORING_INCREASED',
  NULL,
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2024-03-20',
  'NEWS_ALERT_TRIGGERED',
  'Satellite anomaly detected',
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000039',
  '2025-01-15',
  'NEWS_MONITORING_INCREASED',
  NULL,
  'news_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-10-15',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-10-15',
  'COD_ONLY_POLICY_SET',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-10-20',
  'REFERRED_TO_COLLECTIONS',
  NULL,
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-11-01',
  'PROOF_OF_CLAIM_FILED',
  'Proof of claim filed for $487,000',
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2023-08-06',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2023-08-10',
  'REFERRED_TO_COLLECTIONS',
  NULL,
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2023-08-15',
  'PROOF_OF_CLAIM_FILED',
  'Proof of claim filed for $298,000',
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2023-08-07',
  'CREDIT_HOLD_PLACED',
  NULL,
  'Credit Committee',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2023-08-10',
  'PROOF_OF_CLAIM_FILED',
  'Proof of claim filed for $378,000',
  'Finance Dept',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-01-12',
  'SEC_ALERT_TRIGGERED',
  'Going concern warning detected in 10-Q',
  'sec_monitor_agent',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-01-15',
  'PLACED_ON_WATCH_LIST',
  NULL,
  'Jennifer Ramirez',
  'seed'
);
INSERT INTO credit_actions (
  customer_id, action_date, action_type, description,
  performed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-02-05',
  'CREDIT_LIMIT_REDUCTION',
  NULL,
  'Credit Committee',
  'seed'
);

-- SEC MONITORING
INSERT INTO sec_monitoring (
  customer_id, cik, monitoring_active, filing_types_monitored,
  last_10k_date, last_10q_date,
  risk_signals_detected, alert_triggered, alert_date,
  alert_action_taken, next_scheduled_review
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '0001021162',
  TRUE,
  ARRAY['10-K', '10-Q', '8-K'],
  '2024-06-15',
  '2025-01-28',
  ARRAY['CEO_departure', 'covenant_waiver', 'pension_underfunding', 'strategic_review', 'revenue_miss'],
  TRUE,
  '2025-01-28',
  'Watch list. Credit review initiated. New orders require CFO pre-approval.',
  '2025-04-30'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO sec_monitoring (
  customer_id, cik, monitoring_active, filing_types_monitored,
  last_10k_date, last_10q_date,
  risk_signals_detected, alert_triggered, alert_date,
  alert_action_taken, next_scheduled_review
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  '0000217346',
  TRUE,
  ARRAY['10-K', '10-Q', '8-K'],
  '2025-02-15',
  '2024-11-08',
  ARRAY[]::TEXT[],
  FALSE,
  NULL,
  NULL,
  '2025-05-15'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO sec_monitoring (
  customer_id, cik, monitoring_active, filing_types_monitored,
  last_10k_date, last_10q_date,
  risk_signals_detected, alert_triggered, alert_date,
  alert_action_taken, next_scheduled_review
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '0001848948',
  TRUE,
  ARRAY['10-K', '10-Q', '8-K'],
  '2024-03-28',
  '2025-01-12',
  ARRAY['going_concern_warning', 'cash_runway_<3_quarters', 'negative_operating_cash_flow'],
  TRUE,
  '2025-01-12',
  'Credit limit reduced $600K to $400K. Watch list. No new orders without pre-approval.',
  '2025-04-15'
) ON CONFLICT (customer_id) DO NOTHING;

-- SEC FILINGS
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2025-01-28',
  '10-Q',
  'CEO departure disclosed. Q3 revenue missed guidance by 18%. Covenant waiver obtained. Pension underfunded by $84M. Strategic review of portfolio underway. Multiple material weaknesses risk.',
  ARRAY['CEO_departure', 'revenue_miss', 'covenant_waiver', 'pension_underfunding', 'strategic_review'],
  TRUE,
  'sec_monitor_agent',
  'seed'
);
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000021',
  '2024-10-30',
  '10-Q',
  'Q2 results below guidance. Cash position declining. Customer program delays. Lender waiver discussions ongoing.',
  ARRAY['revenue_miss', 'cash_decline', 'lender_waiver_discussions'],
  TRUE,
  'sec_monitor_agent',
  'seed'
);
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  '2025-02-15',
  '10-K',
  'Clean filing. Revenue growth 4.2% YoY. Bell segment strong. Kautex divestiture completed. No material adverse disclosures.',
  ARRAY[]::TEXT[],
  TRUE,
  'sec_monitor_agent',
  'seed'
);
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000048',
  '2024-11-08',
  '10-Q',
  'Q3 beat expectations. Bell helicopter backlog up 18%. Aviation segment margins improved.',
  ARRAY[]::TEXT[],
  TRUE,
  'sec_monitor_agent',
  'seed'
);
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2025-01-12',
  '10-Q',
  'CRITICAL: Going concern warning disclosed. Cash $38M, burn rate $15M/quarter = 2.5 quarters runway. Seeking strategic alternatives. No new customer commitments.',
  ARRAY['going_concern_warning', 'cash_runway_<3_quarters', 'strategic_alternatives_sought'],
  TRUE,
  'sec_monitor_agent',
  'seed'
);
INSERT INTO sec_filings (
  customer_id, filing_date, filing_type,
  key_findings, risk_signals, reviewed, reviewed_by, agent_name
) VALUES (
  'c0000001-0000-0000-0000-000000000049',
  '2024-08-14',
  '10-Q',
  'Cash position declining. Q2 revenue missed guidance by 35%. Workforce reduction 20% announced.',
  ARRAY['revenue_miss', 'workforce_reduction', 'declining_cash_position'],
  TRUE,
  'sec_monitor_agent',
  'seed'
);

-- BANKRUPTCY DETAILS
INSERT INTO bankruptcy_details (
  customer_id, filing_date, case_number, court, chapter, status,
  trustee, reorganization_advisor, legal_counsel,
  proof_of_claim_filed, proof_of_claim_date, proof_of_claim_amount,
  estimated_recovery_rate, estimated_recovery_amount,
  total_pre_petition_claim, emergence_date_estimated, notes
) VALUES (
  'c0000001-0000-0000-0000-000000000035',
  '2024-11-18',
  '23-11993',
  'U.S. Bankruptcy Court, District of New Jersey',
  11,
  'FILED',
  'None — debtor-in-possession',
  'Alvarez & Marsal',
  'Latham & Watkins',
  TRUE,
  '2024-12-01',
  1080000,
  0.22,
  237600,
  1080000,
  'Q3 2025',
  'Estimated recovery 20-25% for general unsecured trade creditors based on comparable airline bankruptcies'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO bankruptcy_details (
  customer_id, filing_date, case_number, court, chapter, status,
  trustee, reorganization_advisor, legal_counsel,
  proof_of_claim_filed, proof_of_claim_date, proof_of_claim_amount,
  estimated_recovery_rate, estimated_recovery_amount,
  total_pre_petition_claim, emergence_date_estimated, notes
) VALUES (
  'c0000001-0000-0000-0000-000000000040',
  '2023-10-15',
  '23-18993',
  'U.S. Bankruptcy Court, District of New Jersey',
  11,
  'CONFIRMED_PLAN',
  'None — debtor-in-possession',
  'FTI Consulting',
  'Kirkland & Ellis',
  TRUE,
  '2023-11-01',
  487000,
  0.28,
  136360,
  487000,
  'Q2 2025',
  'Plan confirmed Aug 2024. Distributions to general unsecured creditors expected Q2 2025 at ~28 cents on dollar'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO bankruptcy_details (
  customer_id, filing_date, case_number, court, chapter, status,
  trustee, reorganization_advisor, legal_counsel,
  proof_of_claim_filed, proof_of_claim_date, proof_of_claim_amount,
  estimated_recovery_rate, estimated_recovery_amount,
  total_pre_petition_claim, emergence_date_estimated, notes
) VALUES (
  'c0000001-0000-0000-0000-000000000041',
  '2023-08-06',
  '23-11069',
  'U.S. Bankruptcy Court, District of Delaware',
  7,
  'CHAPTER_7_CONVERTED',
  'Edmond George, Obermayer Rebmann Maxwell & Hippel',
  'None — Chapter 7 liquidation',
  'Milbank LLP',
  TRUE,
  '2023-08-15',
  298000,
  0.05,
  14900,
  298000,
  'Q4 2025 (liquidation distribution)',
  'Asset sales largely complete. Terminal properties sold. Final distribution to general unsecured creditors expected Q4 2025 at estimated 3-7 cents on dollar'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO bankruptcy_details (
  customer_id, filing_date, case_number, court, chapter, status,
  trustee, reorganization_advisor, legal_counsel,
  proof_of_claim_filed, proof_of_claim_date, proof_of_claim_amount,
  estimated_recovery_rate, estimated_recovery_amount,
  total_pre_petition_claim, emergence_date_estimated, notes
) VALUES (
  'c0000001-0000-0000-0000-000000000042',
  '2023-08-07',
  '23-11120',
  'U.S. Bankruptcy Court, District of Delaware',
  11,
  'ASSETS_SOLD',
  'None — debtor-in-possession through sale',
  'Jefferies LLC',
  'Weil, Gotshal & Manges',
  TRUE,
  '2023-08-10',
  378000,
  0.12,
  45360,
  378000,
  'Q3 2025 (post-sale wind-down distribution)',
  'Assets sold in 363 sale. Remaining estate being administered for distribution to creditors. GUC recovery estimated 10-15%'
) ON CONFLICT (customer_id) DO NOTHING;

-- GROWTH SIGNALS
INSERT INTO growth_signals (
  customer_id, growth_trajectory, revenue_growth_yoy,
  backlog_amount, backlog_description, recent_milestones,
  credit_limit_increase_recommended, recommended_new_limit,
  rationale, upsell_opportunity
) VALUES (
  'c0000001-0000-0000-0000-000000000043',
  'hypergrowth',
  1.85,
  NULL,
  'FAA Part 135 certification obtained Jan 2025; Dubai MOU for 100 aircraft; Toyota $400M investment secured Q4 2024',
  ARRAY['FAA Part 135 certification January 2025', 'Toyota $400M investment closed Q4 2024', 'Dubai RTA MOU signed for 100 aircraft', 'Air Force Agility Prime contract extended'],
  TRUE,
  2000000,
  'FAA certification de-risks commercialization. Strong balance sheet ($2.8B cash). Toyota partnership provides strategic validation. Revenue ramp expected 2025-2026.',
  'Primary titanium/Inconel supplier for production ramp — 100+ aircraft/year at full scale represents ~$8M annual potential'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO growth_signals (
  customer_id, growth_trajectory, revenue_growth_yoy,
  backlog_amount, backlog_description, recent_milestones,
  credit_limit_increase_recommended, recommended_new_limit,
  rationale, upsell_opportunity
) VALUES (
  'c0000001-0000-0000-0000-000000000044',
  'hypergrowth',
  2.1,
  1000000000,
  '100-aircraft order from United Airlines; DOD Urban Air Mobility contract; Stellantis manufacturing partnership',
  ARRAY['United Airlines 100-aircraft firm order Feb 2025', 'U.S. Army Urban Air Mobility contract', 'Stellantis manufacturing JV announced', 'FAA G-1 certification basis agreed'],
  TRUE,
  1500000,
  'United order provides commercial anchor. DOD contract de-risks with government revenue. Manufacturing partnership addresses scale-up risk.',
  'Structural metals and precision components for aircraft production ramp'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO growth_signals (
  customer_id, growth_trajectory, revenue_growth_yoy,
  backlog_amount, backlog_description, recent_milestones,
  credit_limit_increase_recommended, recommended_new_limit,
  rationale, upsell_opportunity
) VALUES (
  'c0000001-0000-0000-0000-000000000045',
  'strong_growth',
  0.28,
  116000000000,
  '$116B total backlog; data center power partnerships with Microsoft, Google, Amazon; offshore wind record orders',
  ARRAY['$116B backlog as of Q3 2024', 'Microsoft AI data center power agreement', 'Amazon sustainable power MOU', 'Offshore wind order book doubled Q4 2024', 'S&P initiated coverage with Buy', 'Nasdaq 100 inclusion Q1 2025'],
  TRUE,
  6000000,
  'GEV is one of 3 global gas turbine OEMs. $116B backlog provides 5+ year revenue visibility. AI data center power boom is structurally multi-year tailwind.',
  'Primary Inconel/nickel superalloy supplier for gas turbine production. Data center demand driving 40%+ order growth in power segment.'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO growth_signals (
  customer_id, growth_trajectory, revenue_growth_yoy,
  backlog_amount, backlog_description, recent_milestones,
  credit_limit_increase_recommended, recommended_new_limit,
  rationale, upsell_opportunity
) VALUES (
  'c0000001-0000-0000-0000-000000000046',
  'strong_growth',
  0.22,
  6200000000,
  '$2.8B SHORAD (Short-Range Air Defense) contract Feb 2025; $6.2B total backlog; Mounted Leader System follow-on',
  ARRAY['$2.8B SHORAD contract award Feb 2025', 'Mounted Leader System follow-on contract Q4 2024', 'Navy integrated combat system program expanded', 'IPO completed 2022 — clean balance sheet'],
  TRUE,
  4000000,
  'SHORAD award is multi-year; provides excellent revenue visibility. Defense spending tailwinds strong. Flawless payment history. Strong balance sheet.',
  'Titanium and aluminum structural components for growing electronics enclosure and chassis production'
) ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO growth_signals (
  customer_id, growth_trajectory, revenue_growth_yoy,
  backlog_amount, backlog_description, recent_milestones,
  credit_limit_increase_recommended, recommended_new_limit,
  rationale, upsell_opportunity
) VALUES (
  'c0000001-0000-0000-0000-000000000047',
  'strong_growth',
  0.32,
  4200000000,
  'Microsoft 1GW fuel cell agreement; $4.2B backlog; multiple AI data center partnerships; South Korea expansion',
  ARRAY['Microsoft 1GW fuel cell supply agreement Q1 2025', 'Shell data center fuel cell partnership', 'South Korea 200MW order', 'Bloom Electrolyzer hydrogen launch'],
  TRUE,
  2500000,
  'Microsoft deal is the single largest fuel cell order in history. Data center power shortage structurally benefits Bloom. Revenue visibility excellent.',
  'Inconel/Hastelloy fuel cell stack components — production volume increasing 3x over next 24 months'
) ON CONFLICT (customer_id) DO NOTHING;

SET session_replication_role = DEFAULT;

-- Verify row counts
SELECT 'company' AS tbl, COUNT(*) AS rows FROM company
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'invoices', COUNT(*) FROM invoices
UNION ALL SELECT 'payment_transactions', COUNT(*) FROM payment_transactions
UNION ALL SELECT 'credit_metrics', COUNT(*) FROM credit_metrics
UNION ALL SELECT 'ar_aging_snapshots', COUNT(*) FROM ar_aging_snapshots
UNION ALL SELECT 'negative_news', COUNT(*) FROM negative_news
UNION ALL SELECT 'credit_events', COUNT(*) FROM credit_events
UNION ALL SELECT 'credit_actions', COUNT(*) FROM credit_actions
UNION ALL SELECT 'sec_monitoring', COUNT(*) FROM sec_monitoring
UNION ALL SELECT 'sec_filings', COUNT(*) FROM sec_filings
UNION ALL SELECT 'bankruptcy_details', COUNT(*) FROM bankruptcy_details
UNION ALL SELECT 'growth_signals', COUNT(*) FROM growth_signals
ORDER BY tbl;