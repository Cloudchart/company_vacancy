$('section[data-name="<%= @block.section %>"]').html("""<%= render(partial: "shared/block", collection: @company.blocks_by_section(@block.section)) -%>""")
