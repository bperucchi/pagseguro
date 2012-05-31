module PagSeguro::Helper
  def pagseguro_form(order, options={})
    options.reverse_merge!(:submit => 'Pagar com PagSeguro', :params => {})
    render :partial => "pag_seguro/pag_seguro_form",
           :locals => {:order => order, :options => options}
  end
end

