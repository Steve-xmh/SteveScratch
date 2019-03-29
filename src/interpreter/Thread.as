/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// Thread.as
// John Maloney, March 2010
//
// Thread is an internal data structure used by the interpreter. It holds the
// state of a thread so it can continue from where it left off, and it has
// a stack to support nested control structures and procedure calls.

package interpreter {
	import blocks.Block;

public class Thread {

	public var target:*;			// object that owns the stack
	public var topBlock:Block;		// top block of the stack
	public var tmpObj:*;			// temporary object (not saved on stack) 临时存储，不保存在栈
	public var startDelayCount:int;	// number of frames to delay before starting

	// the following state is pushed and popped when running substacks
	public var block:Block;
	public var isLoop:Boolean;
	public var firstTime:Boolean;	// used by certain control structures 用于控制结构
	public var tmp:int;				// used by repeat and wait 用来记录等待和循环
	public var args:Array;			// arguments to a user-defined procedure
	public var retBlock:Block;		// 记录这个线程正在调用什么返回值函数

	// the stack
	private var stack:Vector.<StackFrame>;//存储栈
	private var sp:int;

	public function Thread(b:Block, targetObj:*, startupDelay:int = 0) {
		target = targetObj;
		stop();
		topBlock = b;
		startDelayCount = startupDelay;
		// initForBlock
		block = b;
		isLoop = false;
		firstTime = true;
		tmp = 0;
		retBlock = null;
	}
	
	/**
	 * 将方块压入栈
	 * @param	b 需要压入栈的方块
	 */

	public function pushStateForBlock(b:Block):void {
		if (sp >= (stack.length - 1)) growStack();
		var old:StackFrame = stack[sp++];
		old.block = block;
		old.isLoop = isLoop;
		old.firstTime = firstTime;
		old.tmp = tmp;
		old.args = args;
		// initForBlock
		block = b;
		isLoop = false;
		firstTime = true;
		tmp = 0;
		retBlock = null;
	}
	
	/**
	 * 推出上一个保存的栈
	 * @return
	 */
	
	public function popState():Boolean {
		if (sp == 0) return false;
		var old:StackFrame = stack[--sp];
		block		= old.block;
		isLoop		= old.isLoop;
		firstTime	= old.firstTime;
		tmp			= old.tmp;
		args		= old.args;
		retBlock	= old.retBlock;
		return true;
	}

	public function stackEmpty():Boolean { return sp == 0 }
	/**
	 * 停止整个线程
	 */
	public function stop():void {
		block = null;
		stack = new Vector.<StackFrame>(4);
		stack[0] = new StackFrame();
		stack[1] = new StackFrame();
		stack[2] = new StackFrame();
		stack[3] = new StackFrame();
		sp = 0;
	}
	
	/**
	 * 是否为迭代调用，会检测同一个模块是否被迭代调用了5次以上，如检测到则通过保留栈不停循环的形式节约内存
	 * @param	procCall 原调用的模块
	 * @param	procHat 该模块的定义头
	 * @return 如果为迭代模块则返回true，反之亦然
	 */
	
	public function isRecursiveCall(procCall:Block, procHat:Block):Boolean {
		var callCount:int = 5; // maximum number of enclosing procedure calls to examine
		for (var i:int = sp - 1; i >= 0; i--) {
			var b:Block = stack[i].block;
			if (b.op == Specs.CALL || b.op == Specs.FUNCALL) {
				if (procCall == b) return true;
				if (procHat == target.procCache[b.spec]) return true;
			}
			if (--callCount < 0) return false;
		}
		return false;
	}
	/**
	 * 从自定义模块中返回到上一个调用栈中
	 * @return
	 */
	public function returnFromProcedure():Boolean {
		for (var i:int = sp - 1; i >= 0; i--) {
			if (stack[i].block.op == Specs.CALL || stack[i].block.op == Specs.FUNCALL) {
				sp = i + 1;  // 'hack' the stack pointer, but don't do the final popState here
				block = null;  // make it do the final popState through the usual stepActiveThread mechanism
				return true;
			}
		}
		return false;
	}
	/**
	 * 用方块初始化该线程
	 * @param	b 用来入栈的模块
	 */
	private function initForBlock(b:Block):void {
		block = b;
		isLoop = false;
		firstTime = true;
		tmp = 0;
		retBlock = null;
	}

	private function growStack():void {
		// The stack is an array of Thread instances, pre-allocated for efficiency.
		// When growing, the current size is doubled.
		var s:int = stack.length;
		var n:int = s + s;
		stack.length = n;
		for (var i:int = s; i < n; ++i)
			stack[i] = new StackFrame();
	}

}}

import blocks.*;
import interpreter.*;

class StackFrame {
	internal var block:Block;
	internal var isLoop:Boolean;
	internal var firstTime:Boolean;
	internal var tmp:int;
	internal var args:Array;
	internal var retBlock:Block;
}
