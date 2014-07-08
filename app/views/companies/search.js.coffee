$('.companies-search .result').html("<%= j render partial: 'shared/companies/company', collection: @companies %>")
$('.companies-search .counter').html("<%= j render 'counter', collection: @companies %>")
