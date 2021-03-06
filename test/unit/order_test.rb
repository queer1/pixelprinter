require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  before do
    ActiveResource::Base.site = 'http://any-url-for-testing'
  end
  

  context "generating an example order" do
    before do
      @order = order
    end
    
    should "be an instance of ShopifyAPI::Order" do
      assert_instance_of(ShopifyAPI::Order, @order)
    end
  
    should "have an address of type ShopifyAPI::Address" do
      assert_kind_of(ShopifyAPI::Address, @order.shipping_address)
    end
    
    should "have at least one line item" do
      assert @order.line_items.size > 0
      assert_instance_of(ShopifyAPI::LineItem, @order.line_items.first)
    end
    
    should "have at least one tax line" do
      assert @order.tax_lines.size > 0
      assert_instance_of(ShopifyAPI::TaxLine, @order.tax_lines.first)
    end    
    
  end
  
  
  context "#to_liquid" do
    before do
      @order = order
      shop = stub(:name => "My Store", :currency => "USD", :money_format => "$ {{amount}}", :to_liquid => {'name' => "My Store"})
      ShopifyAPI::Shop.stubs(:cached).returns(shop)
      @liquid = @order.to_liquid
      @order_with_one_note_attribute = order('example_order_one_note_attribute.xml')
      @order_with_no_note_attribute = order('example_order_no_note_attribute.xml')
    end

  
    should "respond to #to_liquid" do
      @order = ShopifyAPI::Order.new
      assert_respond_to(@order, :to_liquid)
    end
    
    should "return the current shop with shop_name" do
      assert_equal "My Store", @liquid['shop_name']
    end

    should "return the current shop with shop.name" do
      assert_equal "My Store", @liquid['shop']['name']
    end
    
    should "return total price as cents" do
      assert_equal '1960', @liquid['total_price'].to_s
    end
    
    should "return line item name" do
      assert_equal "Shopify T-Shirt", @liquid['line_items'].first.name
    end
    
    should "return tax line price" do
      assert_equal "2.65", @liquid['tax_lines'].first.price.to_s
    end

    should "return tax line rate" do
      assert_equal "0.1563", @liquid['tax_lines'].first.rate.to_s
    end
    
    should "return tax line title" do
      assert_equal "Taxes", @liquid['tax_lines'].first.title.to_s
    end    
        
    should "return customer email with customer.email" do
      assert_equal 'johnsmith@shopify.com', @liquid['customer']['email']
    end

    should "return note" do
      assert_instance_of Hash, @liquid['attributes']
      assert_equal "My note", @liquid['note']
    end
    
    should "return all attributes as a Hash" do
      assert_instance_of Hash, @liquid['attributes']
      assert_equal "first attr value", @liquid['attributes']['First attribute']
      assert_equal "second attr value", @liquid['attributes']['Second attribute']
    end
    
    should "return nil if Order doesn't have note attributes" do
      assert_equal nil, @order_with_no_note_attribute.to_liquid['attributes']
    end

    should "return a Hash with one key if Order has only one note attribute" do
      assert_equal "first attr value", @order_with_one_note_attribute.to_liquid['attributes']['First attribute']
    end

  end
end