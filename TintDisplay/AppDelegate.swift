//
//  AppDelegate.swift
//  TintDisplay
//
//  Created by Nobuki Yoda.
//  Copyright (c) 2016 Nobuki Yoda. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var color: NSColorWell!
    var statusItem: NSStatusItem?

    var (minR, minG, minB) : (CGGammaValue, CGGammaValue, CGGammaValue) = (0.0, 0.0, 0.0)
    var (maxR, maxG, maxB) : (CGGammaValue, CGGammaValue, CGGammaValue) = (1.0, 1.0, 1.0)
    var (gammaR, gammaG, gammaB) : (CGGammaValue, CGGammaValue, CGGammaValue) = (1.0, 1.0, 1.0)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.mainMenu = appMenu

        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        if let item = statusItem {
            item.image = NSImage(named: "IconMenu")
            item.image?.isTemplate = true
            item.menu = statusMenu
        }

        CGGetDisplayTransferByFormula(
            CGMainDisplayID(),
            &minR, &maxG, &gammaR,
            &minG, &maxG, &gammaG,
            &minB, &maxB, &gammaB
        )
        if let c = customColor() {
            color.color = c
            apply(c)
        }
    }
    
    func customColor() -> NSColor? {
        if let data = UserDefaults.standard.data(forKey: "Color") {
            return NSUnarchiver.unarchiveObject(with: data) as? NSColor
        } else {
            return nil
        }
    }
    
    func apply(_ color: NSColor) {
        let r = CGGammaValue(color.redComponent)
        let g = CGGammaValue(color.greenComponent)
        let b = CGGammaValue(color.blueComponent)
        CGSetDisplayTransferByFormula(CGMainDisplayID(), 0, r, gammaR, 0, g, gammaG, 0, b, gammaB)
    }

    @IBAction func colorChanged(_ sender: NSColorWell) {
        apply(sender.color);
        let data = NSArchiver.archivedData(withRootObject: sender.color);
        UserDefaults.standard.set(data, forKey: "Color");
    }

    @IBAction func applyCustom(_ sender: NSMenuItem) {
        if let c = customColor() {
            apply(c)
        } else {
            CGDisplayRestoreColorSyncSettings()
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        window.makeKeyAndOrderFront(self)
    }
    
    @IBAction func editCustom(_ sender: AnyObject) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func okClicked(_ sender: NSButton) {
        NSApp.hide(self)
    }
    
    @IBAction func resetDefault(_ sender: NSMenuItem) {
        CGDisplayRestoreColorSyncSettings()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        CGDisplayRestoreColorSyncSettings()
    }
}
