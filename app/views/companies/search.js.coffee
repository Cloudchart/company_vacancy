$('.company .result').html("<%= j render 'companies', collection: @companies %>").fadeIn('fast')
