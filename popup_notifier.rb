Plugin.create :popup_notifier do

  #(352,50),(8,8)

  w = Gtk::Window.new
  s = w.display.default_screen
  s = [s.width, s.height]

  @w = (s[1]/58).times.map{|c|
    x = s[0]-360
    y = s[1]-(c+1)*58
    w = Gtk::Window.new(Gtk::Window::POPUP)
    w.resize(352,50)
    w.move(x,y)
    w }

  @n = [false]*@w.size

  def show_popup(widget)
    i = @n.index(false)
    if i != nil then
      @n[i] = true
      @w[i].add(widget)
      @w[i].resize(352,50)
      @w[i].set_size_request(352,50)
      @w[i].show_all
      Reserver.new(UserConfig[:notify_expire_time] || 1){
        Delayer.new{
          @w[i].hide
          @w[i].each{|wi|@w[i].remove(wi)}
          @n[i] = false } } end end

  on_popup_notify do |user, text|
    f = Gtk::Fixed.new
  
    frame = Gtk::EventBox.new
    frame.set_size_request(352,50)
    frame.modify_bg(Gtk::STATE_NORMAL, Gdk::Color.new(0,0,0))
    f.put(frame,0,0)

    i = Gtk::Image.new Gdk::WebImageLoader.pixbuf(user[:profile_image_url], 48, 48){|p|if not i.destroyed? then i.set(p,nil) end }
    layout = Gtk::Layout.new
    layout.set_size_request(48,48)
    layout.modify_bg(Gtk::STATE_NORMAL, Gdk::Color.new(65535,65535,65535))
    layout.add(i)
    f.put(layout,1,1)

    t = '' << user.idname
    t << ' / '
    t << user[:name]
    t << "\n"
    t << text.to_s.gsub("\n","").gsub("&lt;","<").gsub(/&(gt|lt|quot|amp);/){|m| {'gt' => '>', 'lt' => '<', 'quot' => '"', 'amp' => '&'}[$1] }
    l = Gtk::Label.new(t)
    font = Pango::FontDescription.new(Plugin.filtering(:message_font, text, nil).last)
    l.modify_font(font)
    layout = Gtk::Layout.new
    layout.set_size_request(302,48)
    layout.modify_bg(Gtk::STATE_NORMAL, Gdk::Color.new(65535,65535,65535))
    layout.add(l)
    f.put(layout, 49, 1)

    show_popup(f) end
end
