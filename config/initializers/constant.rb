APPOINTMENT_TYPES = ["IA - TELE", "IA or F/U TORO", "IA OR F/U TELE", "IA or F/U TELE", "IA OR F/U TORO",
                     "IA OR F/U", "IA OFFC", "IA TELE", "IA OR F/U OFFC", "IA - IN OFFICE/TELE", "IA TORO", "IA - IN OFFICE", "IA or F/U OFFC", "IA OFFICE"].freeze

BUSINESS_DAYS = { Mon: 1, Tue: 1, Wed: 1, Thu: 1, Fri: 3, Sat: 3, Sun: 2 }.with_indifferent_access

BUSINESS_HOURS = { Mon: 4, Tue: 4, Wed: 2, Thu: 2, Fri: 2, Sat: 2, Sun: 4 }.with_indifferent_access # days to be minus from time for getting actual business hours

TOKEN_REFRESH_DURATION = 1.day

TESTING_CARES = ["Psych Testing"].freeze

INSURANCE_SKIP_OPTION_RULE = "insurance_skip_option_rule".freeze
INSURANCERULE = "InsuranceRule".freeze

AVAILABILITY_BLOCK_OUT_RULE = "availability_block_out_rule".freeze
AVAILABILITY_BLOCK_OUT_DEFAULT = 24

# truncating the decimal places reduces resolution to 111 feet and
# removes some jitter observed in the geo-coder.
LAT_LNG_DECIMAL_PLACES  = 3

RANK_MOST_AVAILABLE = 99
RANK_SOONEST_AVAILABLE = 99