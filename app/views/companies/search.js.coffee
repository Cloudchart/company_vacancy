$('.companies-search .result').html("<%= j render partial: 'company', collection: @companies %>")
$('.companies-search .counter').html("<%= j render 'counter', collection: @companies %>")
