# USAGE:
# ruby combined_pep_list_more_reps.rb ../data/acetylation_profling_10232013.xlsx ../results/acetylation_profling_10232013_summary.xlsx

# combine the list of all replicates in one sheet by peptide seq

require 'rubygems'
require 'rubyXL'
require 'axlsx'

ifile = ARGV[0]
ofile = ARGV[1]

# initialize arguments
workbook = RubyXL::Parser.parse(ifile)

# read the lists (format: prot_acc	prot_desc	pep_score	pep_expect	pep_seq)
combined_list = Hash.new { |h,k| h[k] = [] }
for i in 0..13
	worksheet = workbook[i]
	array = worksheet.extract_data
	array.each do |row|
		if !row[0].include? "prot_acc"
			row_updated = row << i+1 # i+1 is the number of the replicate
			combined_list[row[4]] << row_updated 
		end
	end	
end

# output
results_xlsx = Axlsx::Package.new
results_wb = results_xlsx.workbook

# create sheet
results_wb.add_worksheet(:name => "combined peptide list") do |sheet|
	sheet.add_row ["PROT_ACC", "PROT_DESC", "PEP_SEQ", "ZT_0_1", "ZT_0_2", "ZT_0_3", "ZT_0_4", "ZT_0_5", "ZT_0_6", "ZT_0_7", "ZT_12_1", "ZT_12_2", "ZT_12_3", "ZT_12_4", "ZT_12_5",	"ZT_12_6", "ZT_12_7"]
	combined_list.each_key do |peptide|
		scores = []
		prot_acc = ""
		prot_desc = ""
		combined_list[peptide].each do |value|
			prot_acc = value[0]
			prot_desc = value[1]
			scores[value.last-1] = value[2]	# from 1-based replicates to 0-based array
		end
		(score1, score2, score3, score4, score5, score6, score7, score8, score9, score10, score11, score12, score13, score14) = scores
		row = sheet.add_row [prot_acc, prot_desc, peptide, score1, score2, score3, score4, score5, score6, score7, score8, score9, score10, score11, score12, score13, score14]
	end
end

# write xlsx file
results_xlsx.serialize(ofile)





