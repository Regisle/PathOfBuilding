-- Path of Building
--
-- Class: TimelessJewelPRNG
-- TimelessJewelPRNG
--
local ipairs = ipairs
local t_insert = table.insert
local m_max = math.max
local m_min = math.min
local b_bxor = bit.bxor
local b_rshift = bit.rshift
local b_lshift = bit.lshift

-- Constants


local TimelessJewelPRNGClass = newClass("TimelessJewelPRNG", function(self, seeds)
	self.state = {}
	self.state[0] = 0
	Initialize(seeds)
end


function TimelessJewelPRNGClass:GenerateE(exclusiveMaximumValue)
	return self.GenerateUInt() % exclusiveMaximumValue
end


function TimelessJewelPRNGClass:Generate(minimumValue, maximumValue)
	local a = b_bxor(minimumValue, 0x80000000)
	local b = b_bxor(maximumValue, 0x80000000)
	local roll = self.GenerateE(((b - a) + 1))

	return b_bxor((roll + a), 0x80000000)
end


function TimelessJewelPRNGClass:Initialize(seeds)
	self.state[4] = 0x3793FDFF
	self.state[3] = 0x3CAC5F6F
	self.state[2] = 0xCFA3723C
	self.state[1] = 0x40336050

	local j = 1
	local i = 0
	for i=0,7,1 do
		local k = j % 4 + 1
		local l = (j + 1) % 4 + 1
		local m = (j + 2) % 4 + 1
		local n = (j + 3) % 4 + 1

		local temp = b_bxor(b_bxor(self.state[k], self.state[n]), self.state[l])
		temp = 0x19660D * b_bxor(temp, (b_rshift(temp, 0x1B)))
		self.state[l] = self.state[l] + temp
		temp = j + temp
		if (i < #seeds) then -- (i < seeds.length())
			temp = temp + seeds[i]
		end
		self.state[m] = self.state[m] + temp
		self.state[k] = temp
		j = l - 1
	end
 
	for i=0,4,1 do
		local k = j % 4 + 1
		local l = (j + 1) % 4 + 1
		local m = (j + 2) % 4 + 1
		local n = (j + 3) % 4 + 1

		local temp = self.state[k] + self.state[n] + self.state[l]
		temp = 0x5D588B65 * b_bxor(temp, b_rshift(temp, 0x1B))
		self.state[l] = b_bxor(self.state[l], temp)
		temp = temp - j
		self.state[m] = b_bxor(self.state[m], temp)
		self.state[k] = temp
		j = l - 1
	end
	for i=0,8,1 do
		GenerateNextState()
	end
end

local SHR1 = function(y) return math.floor(y / 2) end
local SHL1 = function(y) return y * 2 end
local SHL10 = function(y) return y * 1024 end

local function AND(a, b)
    local r,p = 0,1
    for i = 0, 31 do
        local a1 = a%2
        local b1 = b%2
        if ((a1>0) and (b1>0)) then r=r+p end
        if (a1>0) then a=a-1 end
        if (b1>0) then b=b-1 end
        a = a/2
        b = b/2
        p = p*2
    end
    return r
end

local function XOR(a, b)
    local r,p = 0,1
    for i = 0, 31 do
        local a1 = a%2
        local b1 = b%2
        if (a1~=b1) then r = r + p end
        if (a1>0) then a=a-1 end
        if (b1>0) then b=b-1 end
        a = a/2
        b = b/2
        p = p*2
    end
    return r
end


function TimelessJewelPRNGClass:GenerateNextState()
    local a = 0
    local b = 0
	local state = self.state
    
    a = state[4]
    b = XOR(XOR(AND(state[1], 0x7FFFFFFF), state[2]), state[3])
    
    a = XOR(a, SHL1(a))
    b = XOR(b, XOR(SHR1(b), a))

    state[1] = state[2]
    state[2] = state[3]
    state[3] = XOR(a, SHL10(b))
    state[4] = b
    
    state[2] = XOR(state[2], AND(-AND(b, 1), 0x8F7011EE))
    state[3] = XOR(state[3], AND(-AND(b, 1), 0xFC78FF1F))
    
    state[0] = state[0] + 1
end

--old partialy done converion, supreceeded by above
function TimelessJewelPRNGClass:GenerateNextStateOLD()
	local a = b_bxor(self.state[4], b_lshift(self.state[4], 1))
	local b = b_bxor(b_bxor((self.state[1] & 0x7FFFFFFF), self.state[2]), self.state[3])
	b = b_bxor(b, b_bxor(b_rshift(b, 1), a))
	
	self.state[1] = self.state[2]
	self.state[2] = self.state[3]
	self.state[3] = b_bxor(a, b_lshift(b, 10))
	self.state[4] = b
	
	-- FIX THIS (Type Cast)
	self.state[2] = b_bxor(self.state[2], ((uint) ((int) (-((int) (b & 1)) & 0x8F7011EE))))
	self.state[3] = b_bxor(self.state[3], ((uint) ((int) (-((int) (b & 1)) & 0xFC78FF1F))))
	
	self.state[0] = self.state[0] + 1
	
--for refference, heres 2 ways to do it in partialy lua converted c#
--[[
	uint a = 0;
	uint b = 0;

	a = self.state[4];
	b = (((self.state[1] & 0x7FFFFFFF) ^ self.state[2]) ^ self.state[3]);

	a = a ^ (a << 1);
	b = b ^ ((b >> 1) ^ a);

	self.state[1] = self.state[2];
	self.state[2] = self.state[3];
	self.state[3] = (a ^ (b << 10));
	self.state[4] = b;

	self.state[2] = self.state[2] ^ ((uint) ((int) (-((int) (b & 1)) & 0x8F7011EE)));
	self.state[3] = self.state[3] ^ ((uint) ((int) (-((int) (b & 1)) & 0xFC78FF1F)));

	self.state[0]++;
	-------------------------------------------------------------------------------------------------------
	uint num1 = self.state[4]
	uint num2 = self.state[1] & (uint) int.MaxValue ^ self.state[2] ^ self.state[3]
	
	num1 = num1 ^ num1 << 1
	num2 = num2 ^ num2 >> 1 ^ num1
	
	self.state[1] = self.state[2]
	self.state[2] = self.state[3]
	self.state[3] = num1 ^ num2 << 10
	self.state[4] = num2
	
	self.state[2] = self.state[2] ^ (uint) (int) ((long) -((int) num2 & 1) & 2406486510L)
	self.state[3] = self.state[3] ^ (uint) (int) ((long) -((int) num2 & 1) & 4235788063L)
	
	self.state[0] = self.state[0] + 1
--]]
end


function TimelessJewelPRNGClass:Temper()
	local a = self.state[4]
	local b = self.state[1] + b_rshift(self.state[3], 8)
	local a = b_bxor(a, b)
	if ((b & 1) != 0)
		a = b_bxor(a, 0x3793FDFF)
	end
	return a
end

function TimelessJewelPRNGClass:GenerateUInt()
	GenerateNextState()
	return Temper()
end

