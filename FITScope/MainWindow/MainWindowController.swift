/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2025 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa
import SwiftFITS

public class MainWindowController: NSWindowController, NSWindowDelegate
{
    private var url:                  URL
    private var onClose:              ( ( MainWindowController ) -> Void )?
    private var file:                 FITSFile?
    private var infoWindowController: InfoWindowController?
    
    @objc private dynamic var loading = false
    
    public init( url: URL, onClose: ( ( MainWindowController ) -> Void )? )
    {
        self.url     = url
        self.onClose = onClose
        
        super.init( window: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.window?.delegate = self
        self.window?.title    = self.url.lastPathComponent
        self.loading          = true
        let url               = self.url
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            do
            {
                let file = try FITSFile( url: url )
                
                DispatchQueue.main.async
                {
                    self.loading = false
                    self.file    = file
                }
            }
            catch
            {
                DispatchQueue.main.async
                {
                    self.loading = false
                    let alert    = NSAlert( error: error )
                    
                    if let window = self.window
                    {
                        alert.beginSheetModal( for: window )
                    }
                    else
                    {
                        alert.runModal()
                    }
                }
            }
        }
    }
    
    public func windowWillClose( _ notification: Notification )
    {
        self.onClose?( self )
    }
    
    @IBAction
    public func showInfo( _ sender: Any? )
    {
        guard let file = self.file
        else
        {
            NSSound.beep()
            
            return
        }
        
        if self.infoWindowController == nil
        {
            self.infoWindowController = InfoWindowController( name: self.url.lastPathComponent, file: file )
        }
        
        self.infoWindowController?.window?.makeKeyAndOrderFront( sender )
    }
}
