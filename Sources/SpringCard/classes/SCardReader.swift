/*
 Copyright (c) 2018-2019 SpringCard - www.springcard.com
 All right reserved
 This software is covered by the SpringCard SDK License Agreement - see LICENSE.txt
 */
import Foundation
import CoreBluetooth
import os.log

/**
Represents a slot

You can get this object with a call to `SCardReaderList.getReader()`

- Remark: This object implements the Equatable protocol
- Version 1.0
- Author: [SpringCard](https://www.springcard.com)
- Copyright: [SpringCard](https://www.springcard.com)
*/
@objc public class SCardReader: NSObject {

	internal var _parent: SCardReaderList!
	internal var _channel: SCardChannel?
	internal var _slotIndex: Int = 0
	internal var _slotName: String = ""
	internal var _cardPowered: Bool = false
	internal var _cardPresent: Bool = false
    private var _wasDiconnected: Bool = false
    private var _slotWasInError: Bool = false
    
    /**
     Contains the slot's index
     
     - Remark: read-only
     */
    @objc public var index: Int {
        return self._slotIndex
    }
    
    /**
     Contains the slot's name
     
     - Remark: read-only
     */
    @objc public var name: String {
        return self._slotName
    }

	/**
	Points to an `SCardReaderList` object
	
	- Remark: read-only
	*/
    @objc public var parent: SCardReaderList! {
		return self._parent
	}
	
    @objc internal var channel: SCardChannel? {
		return self._channel
	}

	/**
	Is card powered (by the application) ?
	
	- Remark: read-only
	*/
    @objc public var cardPowered: Bool {
		return _cardPowered
	}
	
	/**
	Is a card present in the reader (slot) ?
	
	- Remark: read-only
	*/
    @objc public var cardPresent: Bool {
		return _cardPresent
	}
	
	@objc internal init(parent: SCardReaderList, slotName: String, slotIndex: Int) {
		self._parent = parent
		self._slotIndex = slotIndex
		self._slotName = slotName
        super.init()
	}
	
	/// :nodoc:
	public static func == (lhs: SCardReader, rhs: SCardReader) -> Bool {
		return lhs._slotIndex == rhs._slotIndex
	}
	
    internal func setNewState(state: SCCcidStatusSlotStatusNotification) {
        #if DEBUG
		os_log("SCardReader:setNewState()", log: OSLog.libLog, type: .info)
        os_log("Slot Index: %@, new state: %@", log: OSLog.libLog, type: .debug, String(self._slotIndex), String(state.slotStatus.rawValue))
        #endif
		switch state.slotStatus {
			case .cardAbsent: // Card absent, no change since the last notification
                #if DEBUG
                os_log("Card absent, no change since the last notification", log: OSLog.libLog, type: .debug)
                #endif
				self._cardPresent = false
				self._cardPowered = false
			
			case .cardPresent:	// Card present, no change since last notification
                #if DEBUG
                os_log("Card present, no change since last notification", log: OSLog.libLog, type: .debug)
                #endif
				self._cardPresent = true

			case .cardRemoved:	// Card removed notification
                #if DEBUG
                os_log("Card removed notification", log: OSLog.libLog, type: .debug)
                #endif
				self._cardPresent = false
				self._cardPowered = false
            	self.setSlotNotInError()

			case .cardInserted:	// Card inserted notification
                #if DEBUG
                os_log("Card inserted notification", log: OSLog.libLog, type: .debug)
                #endif
				self._cardPresent = true
                self._cardPowered = false
                self._wasDiconnected = false
	            self.setSlotNotInError()
		}
	}

	/**
	Send a direct command to the device
	
	- Parameter command: The command to send to the reader
	- Returns: Nothing, answer is available in the `onControlDidResponse()` callback
	*/
    @objc public func control(command: [UInt8]) {
        #if DEBUG
		os_log("SCardReader:control()", log: OSLog.libLog, type: .info)
        #endif
		parent?.control(command: command)
	}
	
	/**
	Connect to the card (power up + open a communication channel with the card)
	
	- Returns: Nothing, answer is available in the `onCardDidConnect()` callback
	*/
    @objc public func cardConnect() {
        #if DEBUG
		os_log("SCardReader:cardConnect()", log: OSLog.libLog, type: .info)
		os_log("Channel: %s", log: OSLog.libLog, type: .debug, self._slotName)
        #endif
		parent?.cardConnect(reader: self)
	}
	
    @objc internal func setNewChannel(_ channel: SCardChannel) {
		self._channel = channel
	}
    
    @objc internal func unpower() {
        if self._channel != nil {
            self._channel?.setUnpowered()
        }
    }
	
    @objc internal func setCardPowered() {
        self.setSlotNotInError()
		self._cardPowered = true
	}
    
    @objc internal func setCardUnpowered() {
        self._cardPowered = false
    }
    
    @objc internal func setDeconnected() {
        self._wasDiconnected = true
    }
    
    @objc internal func setConnected() {
        self.setSlotNotInError()
    	self._wasDiconnected = false
    }

    @objc internal func wasDisconnected() -> Bool {
        return self._wasDiconnected
    }
    
    @objc internal func setSlotInError() {
        self._slotWasInError = true
    }
    
    @objc internal func setSlotNotInError() {
        self._slotWasInError = false
    }
    
    @objc internal func isSlotInError() -> Bool {
        return self._slotWasInError
    }
}
