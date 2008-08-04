# AeForms

module AeForms
  def ae_form_stylesheet
    <<-END_SRC
<style type="text/css">
form.aeform div.errors {
  background-color: #fcc;
  border: 1px black solid;
  color: black;
  padding-left: 1.5em;
  padding-right: 1.5em;
}

form.aeform h1, form.aeform h2, form.aeform h3, form.aeform h4, form.aeform h5, form.aeform h6 {
  clear: both;
}

form.aeform ul.inline {
    list-style-type: none;
    margin: 0;
    padding: 0;
    text-align: right;
    clear: both;
}

form.aeform ul.inline li {
    margin-right: 1em;
    display: inline;
    font-size: 90%;
}

form.aeform p {
    font-size: 90%;
}

form.aeform select, form.aeform label, form.aeform input {
    float: left;
    margin-bottom: 0.3em;
    font-size: 90%;
}

form.aeform label, form.aeform input {
    display: block;
    width: 65%;
}

form.aeform input[type=hidden] {
    display: none;
}

form.aeform input[type=checkbox] {
    display: inline;
    width: 10pt;
    height: 10pt;
    vertical-align: middle;
    float: none;
}

form.aeform input[type=submit], form.aeform input[type=button] {
    display: inline;
    vertical-align: middle;
    float: none;
    width: auto;
    font-size: 90%;
    height: 1.75em;
}

form.aeform label {
    text-align: right;
    width: 25%;
    padding-right: 3%;
}

form.aeform label.error {
    color: #c00;
}

form.aeform br {
    clear: left;
}

form.aeform fieldset {
  margin-bottom: 0.3em;
  border: none;
  border-top: 1px solid black;
  background-color: #ddd;
}

form.aeform textarea {
    margin-bottom: 0.3em;
    width: 65%;
}

form.aeform legend {
  padding: 1px;
  border: 1px solid black;
  font-weight: bold;
  background-color: #eee;
}
</style>
    END_SRC
  end

  class AeFormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(check_box radio_button hidden_field) + %w(date_select)).each do |selector|
      src = <<-END_SRC
        def label(field, options = {})
          caption = if options.has_key?(:label)
            options.delete(:label)
          else
            field.to_s.humanize
          end
          
          lc = if options.has_key?(:class)
            options.delete(:class)
          else
            ""
          end
          
          if options[:error]
            options.delete(:error)
            lc = lc + " error"
          elsif @template.flash[:error_fields] and @template.flash[:error_fields].include?(field)
            lc = lc + " error"
          end
          
          labelattrs = {:for => field, :class => lc}.update(options)
          @template.content_tag("label", caption + ":", labelattrs)
        end
        
        def #{selector}(field, options = {})
          label(field, options) + super
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
    
    def errors(alttext = nil)
      if @template.flash[:error_messages]
        @template.content_tag("div",
                              @template.content_tag("h2", "There were some errors processing your request.") +
                              @template.content_tag("ul",
                                                    @template.flash[:error_messages].collect do |m|
                                                      @template.content_tag("li", m)
                                                    end) +
                              @template.content_tag("p", "Please correct these errors and resubmit."),
                              :class => "errors")
      elsif not alttext.nil?
        @template.content_tag("p", alttext)
      end
    end

    def select(field, choices, options = {})
      label = options[:label] || field.to_s.humanize
      (@template.content_tag("label", label + ":", :for => field) +
        super +
        @template.content_tag("br"))
    end
  end

  def ae_form_for(name, object = nil, options = nil, &proc)
    options = options || {}
    options[:html] = (options[:html] || {}).merge(:class => "aeform")
    form_for(name, object, options.merge(:builder => AeFormBuilder), &proc)
  end
  
  def authenticity_options
    if protect_against_forgery?
      { :authenticity_token => form_authenticity_token }
    else
      { }
    end
  end
end
